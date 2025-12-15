from flask import Blueprint, render_template, request, redirect, url_for, session, flash, jsonify
from db_helper import DBHelper

sys_bp = Blueprint('sys_admin', __name__)
db = DBHelper()


# =======================
# 1. 基础鉴权与控制台
# =======================

@sys_bp.before_request
def check_admin_login():
    """权限拦截器"""
    if request.endpoint == 'sys_admin.login':
        return
    if 'admin_id' not in session:
        return redirect(url_for('sys_admin.login'))


@sys_bp.route('/login', methods=['GET', 'POST'])
def login():
    """管理员登录"""
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')

        sql = "SELECT * FROM sys_admin WHERE username=%s AND password=%s"
        admin = db.fetch_one(sql, (username, password))

        if admin:
            # 检查账号状态 (适配数据库新增的 status 字段)
            if admin.get('status', 1) == 0:
                flash("该管理员账号已被禁用", "danger")
                return redirect(url_for('sys_admin.login'))

            # 登录管理员前，清除普通用户的脏数据！
            keys_to_remove = ['user_id', 'username', 'level_name', 'discount']
            for key in keys_to_remove:
                session.pop(key, None)

            session['admin_id'] = admin['id']
            session['admin_name'] = admin['nick_name']
            return redirect(url_for('sys_admin.dashboard'))
        else:
            flash("管理员账号或密码错误", "danger")

    return render_template('admin_login.html')


@sys_bp.route('/logout')
def logout():
    """退出登录"""
    session.pop('admin_id', None)
    session.pop('admin_name', None)
    return redirect(url_for('pms.index'))


@sys_bp.route('/')
def dashboard():
    """后台数据看板"""
    res_sales = db.fetch_one("SELECT IFNULL(SUM(total_amount),0) as total FROM oms_order WHERE status > 0")
    res_orders = db.fetch_one("SELECT COUNT(*) as cnt FROM oms_order WHERE DATE(create_time) = CURDATE()")
    res_stock = db.fetch_one("SELECT COUNT(*) as cnt FROM pms_sku_stock WHERE stock < 10")
    latest_orders = db.fetch_all("SELECT * FROM oms_order ORDER BY create_time DESC LIMIT 5")

    return render_template('admin_dashboard.html',
                           sales=res_sales['total'],
                           today_orders=res_orders['cnt'],
                           low_stock=res_stock['cnt'],
                           orders=latest_orders)


# =======================
# 2. 商品管理 (多规格发布 & 列表 & 删除)
# =======================

@sys_bp.route('/product/list')
def product_list():
    """商品列表"""
    # 关联查询库存总量
    sql = """
        SELECT p.*, IFNULL(SUM(s.stock), 0) as total_stock 
        FROM pms_product p
        LEFT JOIN pms_sku_stock s ON p.id = s.product_id
        WHERE p.delete_status = 0 
        GROUP BY p.id 
        ORDER BY p.id DESC
    """
    products = db.fetch_all(sql)
    return render_template('admin_product_list.html', products=products)


@sys_bp.route('/product/delete', methods=['POST'])
def product_delete():
    """商品逻辑删除"""
    pid = request.form.get('id')
    try:
        db.execute_update("UPDATE pms_product SET delete_status=1, publish_status=0 WHERE id=%s", (pid,))
        return jsonify({'code': 200, 'msg': '删除成功'})
    except Exception as e:
        return jsonify({'code': 500, 'msg': str(e)})


@sys_bp.route('/product/add', methods=['GET', 'POST'])
def product_add():
    """发布商品 (多规格支持)"""
    if request.method == 'GET':
        cats = db.fetch_all("SELECT * FROM pms_category")
        brands = db.fetch_all("SELECT * FROM pms_brand")
        return render_template('admin_product_add.html', cats=cats, brands=brands)

    try:
        # 1. 基本信息
        name = request.form.get('name')
        product_sn = request.form.get('product_sn')
        category_name = request.form.get('category_name').strip()
        brand_name = request.form.get('brand_name').strip()
        pic = request.form.get('pic')

        # 2. SKU 数组
        sku_specs = request.form.getlist('sku_specs[]')
        sku_prices = request.form.getlist('sku_prices[]')
        sku_stocks = request.form.getlist('sku_stocks[]')

        if not category_name or not brand_name:
            flash("分类和品牌不能为空", "danger")
            return redirect(url_for('sys_admin.product_add'))

        # 计算最低展示价
        price_list = [float(p) for p in sku_prices]
        min_price = min(price_list) if price_list else 0.00

        conn = db.get_connection()
        try:
            conn.begin()
            with conn.cursor() as cur:
                # 智能分类
                cur.execute("SELECT id FROM pms_category WHERE name=%s", (category_name,))
                cat_res = cur.fetchone()
                if cat_res:
                    cat_id = cat_res['id']
                else:
                    cur.execute("INSERT INTO pms_category (name, parent_id, level, sort) VALUES (%s, 0, 0, 0)",
                                (category_name,))
                    cat_id = cur.lastrowid

                # 智能品牌
                cur.execute("SELECT id FROM pms_brand WHERE name=%s", (brand_name,))
                brand_res = cur.fetchone()
                if brand_res:
                    brand_id = brand_res['id']
                else:
                    cur.execute("INSERT INTO pms_brand (name, product_count) VALUES (%s, 0)", (brand_name,))
                    brand_id = cur.lastrowid

                # 插入商品 SPU
                sql_prod = """
                    INSERT INTO pms_product 
                    (brand_id, category_id, name, pic, product_sn, publish_status, price, sale)
                    VALUES (%s, %s, %s, %s, %s, 1, %s, 0)
                """
                cur.execute(sql_prod, (brand_id, cat_id, name, pic, product_sn, min_price))
                new_pid = cur.lastrowid

                # 循环插入 SKU
                sql_sku = "INSERT INTO pms_sku_stock (product_id, sku_code, price, stock, sp_data) VALUES (%s, %s, %s, %s, %s)"
                for i in range(len(sku_specs)):
                    spec = sku_specs[i]
                    price = sku_prices[i]
                    stock = sku_stocks[i]
                    sku_code = f"{product_sn}_{i + 1}"
                    cur.execute(sql_sku, (new_pid, sku_code, price, stock, spec))

            conn.commit()
            flash(f"商品 '{name}' 发布成功！", "success")
            return redirect(url_for('sys_admin.product_list'))  # 发布后跳回列表更合理

        except Exception as e:
            conn.rollback()
            flash(f"发布失败: {str(e)}", "danger")
            return redirect(url_for('sys_admin.product_add'))
    except Exception as e:
        flash("参数错误", "danger")
        return redirect(url_for('sys_admin.product_add'))


# =======================
# 3. 订单管理
# =======================

@sys_bp.route('/order/ship', methods=['POST'])
def order_ship():
    order_id = request.form.get('order_id')
    db.execute_update("UPDATE oms_order SET status=2 WHERE id=%s", (order_id,))
    return jsonify({'code': 200, 'msg': '发货成功'})


# =======================
# 4. 营销管理 (优惠券) - [适配新数据库结构]
# =======================

@sys_bp.route('/coupon/list')
def coupon_list():
    sql = "SELECT * FROM sms_coupon ORDER BY end_time DESC"
    coupons = db.fetch_all(sql)
    return render_template('admin_coupon_list.html', coupons=coupons)


@sys_bp.route('/coupon/add', methods=['GET', 'POST'])
def coupon_add():
    if request.method == 'GET':
        return render_template('admin_coupon_add.html')

    try:
        name = request.form.get('name')
        amount = float(request.form.get('amount'))
        min_point = float(request.form.get('min_point'))
        publish_count = int(request.form.get('publish_count'))

        start_time_str = request.form.get('start_time')
        end_time_str = request.form.get('end_time')

        # 时间校验
        if start_time_str >= end_time_str:
            flash("发布失败：结束时间必须晚于开始时间！", "danger")
            return redirect(url_for('sys_admin.coupon_add'))

        # 格式化时间 (HTML T -> MySQL 空格)
        start_time = start_time_str.replace('T', ' ')
        end_time = end_time_str.replace('T', ' ')

        # 插入包含新字段 (start_time, enable_status)
        sql = """
            INSERT INTO sms_coupon 
            (name, amount, min_point, start_time, end_time, publish_count, receive_count, enable_status)
            VALUES (%s, %s, %s, %s, %s, %s, 0, 1)
        """
        db.execute_update(sql, (name, amount, min_point, start_time, end_time, publish_count))

        flash("优惠券发布成功！", "success")
        return redirect(url_for('sys_admin.coupon_list'))

    except Exception as e:
        flash(f"发布失败: {str(e)}", "danger")
        return redirect(url_for('sys_admin.coupon_add'))


@sys_bp.route('/coupon/delete', methods=['POST'])
def coupon_delete():
    cid = request.form.get('id')
    try:
        db.execute_update("DELETE FROM sms_coupon WHERE id=%s", (cid,))
        return jsonify({'code': 200, 'msg': '删除成功'})
    except Exception as e:
        return jsonify({'code': 500, 'msg': str(e)})


# MallProject/sys_admin/views.py

# =======================
# 5. 分类管理模块 (新增)
# =======================

@sys_bp.route('/category/list')
def category_list():
    """分类列表页"""
    # 查询分类，并统计每个分类下有多少个商品 (关联查询)
    sql = """
        SELECT c.*, COUNT(p.id) as product_count 
        FROM pms_category c 
        LEFT JOIN pms_product p ON c.id = p.category_id 
        GROUP BY c.id 
        ORDER BY c.sort ASC
    """
    cats = db.fetch_all(sql)
    return render_template('admin_category_list.html', cats=cats)


@sys_bp.route('/category/add', methods=['POST'])
def category_add():
    """快速添加分类"""
    name = request.form.get('name')
    sort = request.form.get('sort', 0)

    if not name:
        return jsonify({'code': 400, 'msg': '名称不能为空'})

    try:
        sql = "INSERT INTO pms_category (name, parent_id, level, sort) VALUES (%s, 0, 0, %s)"
        db.execute_update(sql, (name, sort))
        return jsonify({'code': 200, 'msg': '添加成功'})
    except Exception as e:
        return jsonify({'code': 500, 'msg': str(e)})


@sys_bp.route('/category/delete', methods=['POST'])
def category_delete():
    """
    删除分类 (核心逻辑)
    """
    cat_id = request.form.get('id')

    # 1. [核心检查] 检查该分类下是否有商品
    # 注意：这里我们不仅查 pms_product，最好也查一下是否有子分类(如果你的系统支持多级分类)
    product_count = db.fetch_one("SELECT COUNT(*) as cnt FROM pms_product WHERE category_id=%s", (cat_id,))

    if product_count['cnt'] > 0:
        # 如果有商品，直接拒绝，并告诉前端有多少个商品
        return jsonify(
            {'code': 400, 'msg': f'删除失败：该分类下仍有 {product_count["cnt"]} 件商品！请先转移或删除这些商品。'})

    # 2. 如果是空分类，允许删除
    try:
        db.execute_update("DELETE FROM pms_category WHERE id=%s", (cat_id,))
        return jsonify({'code': 200, 'msg': '删除成功'})
    except Exception as e:
        return jsonify({'code': 500, 'msg': str(e)})