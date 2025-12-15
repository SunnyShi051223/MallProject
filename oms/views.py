from flask import Blueprint, render_template, request, redirect, url_for, session, flash
from db_helper import DBHelper


# 假设 blueprint 名称为 oms_bp
# oms_bp = Blueprint('oms', __name__)
# db = DBHelper()

@oms_bp.route('/my_orders')
def my_orders():
    """
    订单列表页：包含退货状态查询
    """
    user_id = session.get('user_id')
    if not user_id:
        return redirect('/user/login')

    # 使用 LEFT JOIN 查出订单是否有对应的退货申请记录
    # ra.status AS return_status: 0待处理, 1已同意, 2已拒绝, NULL无申请
    sql = """
        SELECT o.*, ra.status AS return_status, ra.id AS return_id
        FROM oms_order o
        LEFT JOIN oms_order_return_apply ra ON o.id = ra.order_id
        WHERE o.member_id = %s
        ORDER BY o.create_time DESC
    """
    orders = db.fetch_all(sql, (user_id,))

    # 渲染时使用 order_list.html (放在 templates 根目录)
    return render_template('order_list.html', orders=orders)


@oms_bp.route('/return_page/<int:order_id>')
def return_page(order_id):
    """
    展示退货申请页面 (带拦截逻辑)
    """
    user_id = session.get('user_id')
    if not user_id:
        return redirect('/user/login')

    # 1. 校验订单归属
    sql = "SELECT * FROM oms_order WHERE id=%s AND member_id=%s"
    order = db.fetch_one(sql, (order_id, user_id))

    if not order:
        flash("订单不存在或您无权操作")
        return redirect(url_for('oms.my_orders'))

    if order['status'] != 3:
        flash("只有【已完成】的订单才能申请售后服务")
        return redirect(url_for('oms.my_orders'))

    # 2. 校验是否已申请过 (防止直接输URL访问)
    check_sql = "SELECT id FROM oms_order_return_apply WHERE order_id=%s"
    has_applied = db.fetch_one(check_sql, (order_id,))

    if has_applied:
        flash("该订单已提交过退货申请，请勿重复操作")
        return redirect(url_for('oms.my_orders'))

    return render_template('return_apply.html', order=order)


@oms_bp.route('/apply_return', methods=['POST'])
def apply_return():
    """
    提交退货申请 (带拦截逻辑)
    """
    user_id = session.get('user_id')
    if not user_id:
        return redirect('/user/login')

    order_id = request.form.get('order_id')
    reason = request.form.get('reason')

    if not reason or not reason.strip():
        flash("请填写退货原因")
        return redirect(url_for('oms.return_page', order_id=order_id))

    try:
        # 1. 再次校验是否存在申请 (防重复提交)
        check_exist_sql = "SELECT id FROM oms_order_return_apply WHERE order_id=%s"
        if db.fetch_one(check_exist_sql, (order_id,)):
            flash("请勿重复提交退货申请！")
            return redirect(url_for('oms.my_orders'))

        # 2. 校验订单状态
        check_status_sql = "SELECT status FROM oms_order WHERE id=%s AND member_id=%s"
        order = db.fetch_one(check_status_sql, (order_id, user_id))

        if not order or order['status'] != 3:
            flash("订单状态异常，无法申请")
            return redirect(url_for('oms.my_orders'))

        # 3. 插入申请
        insert_sql = """
            INSERT INTO oms_order_return_apply (order_id, status, reason, create_time)
            VALUES (%s, 0, %s, NOW())
        """
        db.execute_update(insert_sql, (order_id, reason))

        flash("✅ 退货申请已提交，客服将尽快审核！")
        return redirect(url_for('oms.my_orders'))

    except Exception as e:
        print(f"退货申请失败: {e}")
        flash("系统繁忙，请稍后再试")
        return redirect(url_for('oms.my_orders'))