from flask import Blueprint, render_template, request, redirect, url_for, flash, session
from db_helper import DBHelper


# 请根据您实际的蓝图名称修改，例如: admin_bp = Blueprint('sys_admin', __name__)
# 这里假设您的蓝图对象叫 admin_bp，数据库实例叫 db

@admin_bp.route('/return_list')
def return_list():
    """
    展示所有退货申请列表
    """
    if not session.get('admin_id'):
        return redirect('/admin/login')

    # 关联查询：获取申请单信息 + 订单号 + 订单金额
    sql = """
        SELECT r.*, o.order_sn, o.total_amount, o.member_id 
        FROM oms_order_return_apply r
        JOIN oms_order o ON r.order_id = o.id
        ORDER BY r.create_time DESC
    """
    apply_list = db.fetch_all(sql)

    return render_template('admin_return_list.html', apply_list=apply_list)


@admin_bp.route('/handle_return', methods=['POST'])
def handle_return():
    """
    处理退货审核：同意 或 拒绝
    """
    if not session.get('admin_id'):
        return redirect('/admin/login')

    apply_id = request.form.get('apply_id')
    action = request.form.get('action')  # 'agree' 或 'reject'

    if not apply_id or not action:
        flash("参数错误")
        return redirect(url_for('admin.return_list'))  # 注意蓝图前缀

    try:
        if action == 'agree':
            # === 同意退货 ===
            # 1. 申请单状态 -> 1 (已通过)
            update_apply_sql = "UPDATE oms_order_return_apply SET status=1 WHERE id=%s"
            db.execute_update(update_apply_sql, (apply_id,))

            # 2. 原订单状态 -> 4 (已关闭/退款完成)
            # 先查出对应的 order_id
            get_order_sql = "SELECT order_id FROM oms_order_return_apply WHERE id=%s"
            res = db.fetch_one(get_order_sql, (apply_id,))
            if res:
                close_order_sql = "UPDATE oms_order SET status=4 WHERE id=%s"
                db.execute_update(close_order_sql, (res['order_id'],))

            flash("操作成功：已同意退货，关联订单已关闭。")

        elif action == 'reject':
            # === 拒绝退货 ===
            # 1. 申请单状态 -> 2 (已拒绝)
            # 2. 原订单状态不变 (保持已完成)
            update_sql = "UPDATE oms_order_return_apply SET status=2 WHERE id=%s"
            db.execute_update(update_sql, (apply_id,))

            flash("操作成功：已拒绝退货申请。")

    except Exception as e:
        print(f"处理失败: {e}")
        flash("系统错误，操作失败")

    return redirect(url_for('admin.return_list'))  # 注意蓝图前缀