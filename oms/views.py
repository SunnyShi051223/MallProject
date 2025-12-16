from flask import Blueprint, render_template, request, redirect, url_for, session, flash, jsonify
from db_helper import DBHelper
import datetime
import uuid

# =================================================
# 蓝图与数据库初始化
# =================================================
oms_bp = Blueprint('oms', __name__)
db = DBHelper()


@oms_bp.route('/cart')
def view_cart():
    """查看购物车"""
    user_id = session.get('user_id')
    if not user_id:
        return redirect(url_for('ums.login'))

    # 获取用户等级折扣
    discount = session.get('discount', 1.0)
    level_name = session.get('level_name', '普通会员')

    sql = "SELECT * FROM oms_cart_item WHERE member_id=%s ORDER BY create_date DESC"
    items = db.fetch_all(sql, (user_id,))

    # 计算原价总额 (Decimal 类型)
    raw_total = sum(item['price'] * item['quantity'] for item in items)

    # 计算折后总额
    # 🔧【修复点】：将 Decimal 转为 float 再计算，防止报错
    total = float(raw_total) * discount

    # 获取可用优惠券
    now = datetime.datetime.now()
    sql_coupons = """
        SELECT h.id AS history_id, c.name, c.amount, c.min_point
        FROM sms_coupon_history h
        JOIN sms_coupon c ON h.coupon_id = c.id
        WHERE h.member_id = %s 
          AND h.use_status = 0 
          AND c.end_time > %s
          AND c.min_point <= %s
    """
    coupons = db.fetch_all(sql_coupons, (user_id, now, total))

    return render_template('cart.html', items=items, total=total, raw_total=raw_total,
                           discount=discount, level_name=level_name, coupons=coupons)


@oms_bp.route('/add_to_cart', methods=['POST'])
def add_to_cart():
    user_id = session.get('user_id')
    if not user_id:
        return jsonify({'code': 401, 'msg': '请先登录'})

    sku_id = request.form.get('sku_id')
    quantity = int(request.form.get('quantity', 1))

    # 查询商品信息
    sku_sql = """
        SELECT s.id, s.price, s.sku_code, s.sp_data, p.id as pid, p.name, p.pic 
        FROM pms_sku_stock s
        JOIN pms_product p ON s.product_id = p.id
        WHERE s.id = %s
    """
    sku_info = db.fetch_one(sku_sql, (sku_id,))
    if not sku_info:
        return jsonify({'code': 400, 'msg': '规格不存在'})

    # 检查购物车是否已存在
    exist = db.fetch_one("SELECT id FROM oms_cart_item WHERE member_id=%s AND product_sku_id=%s", (user_id, sku_id))

    if exist:
        db.execute_update("UPDATE oms_cart_item SET quantity = quantity + %s WHERE id=%s", (quantity, exist['id']))
    else:
        insert = """
            INSERT INTO oms_cart_item (member_id, product_id, product_sku_id, quantity, price, product_pic, product_name, product_sku_code, product_attr)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        db.execute_update(insert, (
            user_id, sku_info['pid'], sku_info['id'], quantity, sku_info['price'],
            sku_info['pic'], sku_info['name'], sku_info['sku_code'], sku_info['sp_data']
        ))

    return jsonify({'code': 200, 'msg': '已加入购物车'})


@oms_bp.route('/delete_cart_item', methods=['POST'])
def delete_cart_item():
    cart_id = request.form.get('cart_id')
    db.execute_update("DELETE FROM oms_cart_item WHERE id=%s", (cart_id,))
    return jsonify({'code': 200, 'msg': '已删除'})


@oms_bp.route('/submit_order', methods=['POST'])
def submit_order():
    """提交订单 (含事务)"""
    user_id = session.get('user_id')
    if not user_id:
        return jsonify({'code': 401, 'msg': '登录已过期'})

    member_coupon_id = request.form.get('member_coupon_id')  # 用户领取的优惠券ID (history_id)

    # 1. 检查购物车
    cart_items = db.fetch_all("SELECT * FROM oms_cart_item WHERE member_id=%s", (user_id,))
    if not cart_items:
        return jsonify({'code': 400, 'msg': '购物车为空'})

    # 2. 检查地址
    address = db.fetch_one(
        "SELECT * FROM ums_member_receive_address WHERE member_id=%s ORDER BY default_status DESC LIMIT 1", (user_id,))
    if not address:
        return jsonify({'code': 400, 'msg': '请先添加收货地址'})

    # 3. 计算金额
    # 注意：这里计算出来的是 Decimal
    raw_amount = sum(item['price'] * item['quantity'] for item in cart_items)

    # 转 float 计算折扣
    discount = session.get('discount', 1.0)
    member_amount = float(raw_amount) * discount  # 会员折后价
    final_amount = member_amount

    conn = db.get_connection()
    try:
        conn.begin()

        # 4. 扣减优惠券
        if member_coupon_id:
            sql_coupon = """
                SELECT h.id, c.amount, c.min_point, c.end_time 
                FROM sms_coupon_history h
                JOIN sms_coupon c ON h.coupon_id = c.id
                WHERE h.id = %s AND h.member_id = %s AND h.use_status = 0
            """
            with conn.cursor() as cur:
                cur.execute(sql_coupon, (member_coupon_id, user_id))
                coupon = cur.fetchone()

            if not coupon:
                raise Exception("优惠券无效")
            if coupon['end_time'] < datetime.datetime.now():
                raise Exception("优惠券已过期")
            # 比较时要把 member_amount (float) 和 min_point (Decimal) 统一
            if member_amount < float(coupon['min_point']):
                raise Exception(f"未满 {coupon['min_point']} 元，无法使用此券")

            final_amount = member_amount - float(coupon['amount'])
            if final_amount < 0: final_amount = 0

            # 标记优惠券已用
            with conn.cursor() as cur:
                cur.execute("UPDATE sms_coupon_history SET use_status=1, use_time=NOW() WHERE id=%s",
                            (member_coupon_id,))

        # 5. 生成订单
        order_sn = datetime.datetime.now().strftime('%Y%m%d%H%M%S') + str(user_id)
        sql_order = """
            INSERT INTO oms_order 
            (member_id, order_sn, total_amount, status, receiver_name, receiver_phone, receiver_detail_address)
            VALUES (%s, %s, %s, 0, %s, %s, %s)
        """
        with conn.cursor() as cur:
            cur.execute(sql_order, (
            user_id, order_sn, final_amount, address['name'], address['phone_number'], address['detail_address']))
            order_id = cur.lastrowid

        # 6. 扣库存 & 插入订单项
        for item in cart_items:
            # 扣库存 (乐观锁)
            sql_stock = "UPDATE pms_sku_stock SET stock = stock - %s WHERE id = %s AND stock >= %s"
            with conn.cursor() as cur:
                affected = cur.execute(sql_stock, (item['quantity'], item['product_sku_id'], item['quantity']))
                if affected == 0:
                    raise Exception(f"商品 {item['product_name']} 库存不足")

            # 插入订单项
            sql_item = """
                INSERT INTO oms_order_item (order_id, order_sn, product_id, product_sku_id, product_name, product_price, product_quantity, product_attr)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """
            with conn.cursor() as cur:
                cur.execute(sql_item, (order_id, order_sn, item['product_id'], item['product_sku_id'],
                                       item['product_name'], item['price'], item['quantity'], item['product_attr']))

        # 7. 清空购物车
        with conn.cursor() as cur:
            cur.execute("DELETE FROM oms_cart_item WHERE member_id=%s", (user_id,))

        conn.commit()
        return jsonify({'code': 200, 'msg': '下单成功', 'order_sn': order_sn})

    except Exception as e:
        conn.rollback()
        return jsonify({'code': 500, 'msg': str(e)})
    finally:
        conn.close()


# --- 订单列表 & 退货逻辑 ---

@oms_bp.route('/my_orders')
def my_orders():
    user_id = session.get('user_id')
    if not user_id:
        return redirect('/ums/login')

    sql = """
        SELECT o.*, ra.status AS return_status, ra.id AS return_id
        FROM oms_order o
        LEFT JOIN oms_order_return_apply ra ON o.id = ra.order_id
        WHERE o.member_id = %s
        ORDER BY o.create_time DESC
    """
    orders = db.fetch_all(sql, (user_id,))

    return render_template('order_list.html', orders=orders)


@oms_bp.route('/return_page/<int:order_id>')
def return_page(order_id):
    user_id = session.get('user_id')
    if not user_id:
        return redirect('/ums/login')

    sql = "SELECT * FROM oms_order WHERE id=%s AND member_id=%s"
    order = db.fetch_one(sql, (order_id, user_id))

    if not order:
        flash("订单不存在")
        return redirect(url_for('oms.my_orders'))

    if order['status'] != 3:
        flash("只有【已完成】的订单才能申请售后服务")
        return redirect(url_for('oms.my_orders'))

    check_sql = "SELECT id FROM oms_order_return_apply WHERE order_id=%s"
    has_applied = db.fetch_one(check_sql, (order_id,))
    if has_applied:
        flash("该订单已申请过售后，请勿重复操作")
        return redirect(url_for('oms.my_orders'))

    return render_template('return_apply.html', order=order)


@oms_bp.route('/apply_return', methods=['POST'])
def apply_return():
    user_id = session.get('user_id')
    if not user_id:
        return redirect('/ums/login')

    order_id = request.form.get('order_id')
    reason = request.form.get('reason')

    if not reason:
        flash("请填写退货原因")
        return redirect(url_for('oms.return_page', order_id=order_id))

    try:
        if db.fetch_one("SELECT id FROM oms_order_return_apply WHERE order_id=%s", (order_id,)):
            flash("请勿重复提交")
            return redirect(url_for('oms.my_orders'))

        sql = "INSERT INTO oms_order_return_apply (order_id, status, reason, create_time) VALUES (%s, 0, %s, NOW())"
        db.execute_update(sql, (order_id, reason))

        flash("✅ 申请提交成功，请等待客服审核")
        return redirect(url_for('oms.my_orders'))

    except Exception as e:
        print(e)
        flash("系统繁忙")
        return redirect(url_for('oms.my_orders'))


@oms_bp.route('/pay_order', methods=['POST'])
def pay_order():
    order_id = request.form.get('order_id')
    user_id = session.get('user_id')

    check = db.fetch_one("SELECT id FROM oms_order WHERE id=%s AND member_id=%s AND status=0", (order_id, user_id))
    if not check:
        return jsonify({'code': 400, 'msg': '订单状态异常'})

    db.execute_update("UPDATE oms_order SET status=1 WHERE id=%s", (order_id,))
    return jsonify({'code': 200, 'msg': '支付成功'})


@oms_bp.route('/cancel_order', methods=['POST'])
def cancel_order():
    order_id = request.form.get('order_id')
    db.execute_update("UPDATE oms_order SET status=4 WHERE id=%s", (order_id,))
    return jsonify({'code': 200, 'msg': '已取消'})


@oms_bp.route('/confirm_receipt', methods=['POST'])
def confirm_receipt():
    order_id = request.form.get('order_id')
    db.execute_update("UPDATE oms_order SET status=3 WHERE id=%s", (order_id,))
    return jsonify({'code': 200, 'msg': '交易完成'})