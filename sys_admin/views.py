from flask import Blueprint, render_template, request, redirect, url_for, session, flash, jsonify
from db_helper import DBHelper

sys_bp = Blueprint('sys_admin', __name__)
db = DBHelper()


# --- 权限拦截 ---
@sys_bp.before_request
def check_admin_login():
    if request.endpoint == 'sys_admin.login':
        return
    if 'admin_id' not in session:
        return redirect(url_for('sys_admin.login'))


# --- 基础功能 ---
@sys_bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'GET':
        return render_template('admin_login.html')

    username = request.form.get('username')
    password = request.form.get('password')

    admin = db.fetch_one("SELECT * FROM sys_admin WHERE username=%s AND password=%s", (username, password))

    if admin:
        if admin['status'] == 0:
            flash("账号已被禁用", "danger")
            return redirect(url_for('sys_admin.login'))

        session['admin_id'] = admin['id']
        session['admin_name'] = admin['nick_name']
        return redirect(url_for('sys_admin.dashboard'))
    else:
        flash("账号或密码错误", "danger")
        return redirect(url_for('sys_admin.login'))


@sys_bp.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('sys_admin.login'))


@sys_bp.route('/')
@sys_bp.route('/dashboard')
def dashboard():
    # 仪表盘统计数据
    sales = db.fetch_one("SELECT IFNULL(SUM(total_amount),0) as total FROM oms_order WHERE status > 0")
    today_orders = db.fetch_one("SELECT COUNT(*) as cnt FROM oms_order WHERE DATE(create_time) = CURDATE()")
    low_stock = db.fetch_one("SELECT COUNT(*) as cnt FROM pms_sku_stock WHERE stock < 10")
    latest_orders = db.fetch_all("SELECT * FROM oms_order ORDER BY create_time DESC LIMIT 5")

    return render_template('admin_dashboard.html',
                           sales=sales['total'],
                           today_orders=today_orders['cnt'],
                           low_stock=low_stock['cnt'],
                           orders=latest_orders)


# --- 📦 商品管理 (修复 404) ---
@sys_bp.route('/product_list')  # 对应 dashboard 的 /admin/product_list
def product_list():
    # 关联查询总库存
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


@sys_bp.route('/product/add', methods=['GET', 'POST'])
def product_add():
    if request.method == 'GET':
        cats = db.fetch_all("SELECT * FROM pms_category")
        brands = db.fetch_all("SELECT * FROM pms_brand")
        return render_template('admin_product_add.html', cats=cats, brands=brands)

    # 处理商品发布
    try:
        name = request.form.get('name')
        sn = request.form.get('product_sn')
        cat_name = request.form.get('category_name')
        brand_name = request.form.get('brand_name')
        pic = request.form.get('pic')

        # 简化逻辑：假设分类和品牌已存在或使用默认ID
        cat_res = db.fetch_one("SELECT id FROM pms_category WHERE name=%s", (cat_name,))
        cat_id = cat_res['id'] if cat_res else 1

        brand_res = db.fetch_one("SELECT id FROM pms_brand WHERE name=%s", (brand_name,))
        brand_id = brand_res['id'] if brand_res else 1

        conn = db.get_connection()
        conn.begin()
        with conn.cursor() as cur:
            # 插入主表
            cur.execute("""
                INSERT INTO pms_product (brand_id, category_id, name, pic, product_sn, publish_status, price, sale)
                VALUES (%s, %s, %s, %s, %s, 1, 0, 0)
            """, (brand_id, cat_id, name, pic, sn))
            pid = cur.lastrowid

            # 插入 SKU
            specs = request.form.getlist('sku_specs[]')
            prices = request.form.getlist('sku_prices[]')
            stocks = request.form.getlist('sku_stocks[]')

            min_price = min([float(p) for p in prices]) if prices else 0
            cur.execute("UPDATE pms_product SET price=%s WHERE id=%s", (min_price, pid))

            for i in range(len(specs)):
                cur.execute("""
                    INSERT INTO pms_sku_stock (product_id, sku_code, price, stock, sp_data)
                    VALUES (%s, %s, %s, %s, %s)
                """, (pid, sn + '_' + str(i), prices[i], stocks[i], specs[i]))

        conn.commit()
        flash(f"商品 '{name}' 发布成功！", "success")
        return redirect(url_for('sys_admin.product_list'))

    except Exception as e:
        flash(f"发布失败: {str(e)}", "danger")
        return redirect(url_for('sys_admin.product_add'))


@sys_bp.route('/product/delete', methods=['POST'])
def product_delete():
    pid = request.form.get('id')
    db.execute_update("UPDATE pms_product SET delete_status=1 WHERE id=%s", (pid,))
    return jsonify({'code': 200})


# --- 🧾 订单管理 (修复 404) ---
@sys_bp.route('/order_list')  # 对应 dashboard 的 /admin/order_list
def order_list():
    sql = "SELECT * FROM oms_order ORDER BY create_time DESC"
    orders = db.fetch_all(sql)
    return render_template('admin_order_list.html', orders=orders)


@sys_bp.route('/order/ship', methods=['POST'])
def order_ship():
    order_id = request.form.get('order_id')
    db.execute_update("UPDATE oms_order SET status=2 WHERE id=%s", (order_id,))
    return jsonify({'code': 200})


# --- 🎫 优惠券管理 ---
@sys_bp.route('/coupon_list')
def coupon_list():
    coupons = db.fetch_all("SELECT * FROM sms_coupon ORDER BY id DESC")
    return render_template('admin_coupon_list.html', coupons=coupons)


@sys_bp.route('/coupon/add', methods=['GET', 'POST'])
def coupon_add():
    if request.method == 'GET':
        return render_template('admin_coupon_add.html')

    # 接收表单
    name = request.form.get('name')
    amount = request.form.get('amount')
    min_point = request.form.get('min_point')
    start = request.form.get('start_time')
    end = request.form.get('end_time')
    count = request.form.get('publish_count')

    sql = """
        INSERT INTO sms_coupon (name, amount, min_point, start_time, end_time, publish_count, receive_count)
        VALUES (%s, %s, %s, %s, %s, %s, 0)
    """
    db.execute_update(sql, (name, amount, min_point, start, end, count))
    flash("优惠券发布成功", "success")
    return redirect(url_for('sys_admin.coupon_list'))


@sys_bp.route('/coupon/delete', methods=['POST'])
def coupon_delete():
    cid = request.form.get('id')
    db.execute_update("DELETE FROM sms_coupon WHERE id=%s", (cid,))
    return jsonify({'code': 200})


# --- ↩️ 售后处理 (之前写的功能) ---
@sys_bp.route('/return_list')
def return_list():
    sql = """
        SELECT r.*, o.order_sn, o.total_amount, o.member_id 
        FROM oms_order_return_apply r
        JOIN oms_order o ON r.order_id = o.id
        ORDER BY r.create_time DESC
    """
    apply_list = db.fetch_all(sql)
    return render_template('admin_return_list.html', apply_list=apply_list)


@sys_bp.route('/handle_return', methods=['POST'])
def handle_return():
    apply_id = request.form.get('apply_id')
    action = request.form.get('action')

    try:
        if action == 'agree':
            db.execute_update("UPDATE oms_order_return_apply SET status=1 WHERE id=%s", (apply_id,))
            res = db.fetch_one("SELECT order_id FROM oms_order_return_apply WHERE id=%s", (apply_id,))
            if res:
                db.execute_update("UPDATE oms_order SET status=4 WHERE id=%s", (res['order_id'],))
            flash("操作成功：已同意退货")

        elif action == 'reject':
            db.execute_update("UPDATE oms_order_return_apply SET status=2 WHERE id=%s", (apply_id,))
            flash("操作成功：已拒绝退货")

    except Exception as e:
        flash(f"操作失败: {e}")

    return redirect(url_for('sys_admin.return_list'))