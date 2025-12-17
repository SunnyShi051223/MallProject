from flask import Blueprint, request, jsonify
from openai import OpenAI
from db_helper import DBHelper
from flask import Blueprint, request, jsonify, render_template
import json

# 创建蓝图
ai_bp = Blueprint('ai', __name__)

# ==========================================
# 1. 配置通义千问 (使用 OpenAI SDK 兼容模式)
# ==========================================
client = OpenAI(
            api_key="sk-cc0a8af819144e0ca7333124f5f3181b",
            base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",
        )

# ==========================================
# 2. 定义 Prompt (数据库说明书)
# ==========================================
# 这里通过 Prompt Engineering 告诉 AI 数据库结构和安全约束
DB_SCHEMA_PROMPT = """
你是一个 MySQL 专家。请根据以下数据库表结构，将用户的自然语言转换为 SQL 查询语句。

【表结构】：
1. 商品表 pms_product (
   - id: 商品ID
   - name: 商品名称 (模糊查询请用 LIKE)
   - price: 展示价格
   - product_sn: 货号
   - delete_status: 删除状态 (0正常, 1删除。查询时必须加上 WHERE delete_status=0)
)
2. 库存表 pms_sku_stock (
   - product_id: 关联商品ID
   - sku_code: SKU编码
   - price: 实际销售价
   - stock: 库存数量
   - sp_data: 规格描述(如颜色、尺寸)
)

【严格规则】：
1. 只返回 SQL 语句本身，不要返回 markdown 格式（不要 ```sql ... ```），不要任何解释文字。
2. 总是限制返回行数 (LIMIT 10)。
3. 如果用户查询“库存”、“规格”或“具体哪一款”，请使用 JOIN 连接 pms_product 和 pms_sku_stock。
4. 如果用户询问“最贵”、“最便宜”，请使用 ORDER BY price DESC/ASC LIMIT 1。
5. 绝对禁止生成 INSERT, UPDATE, DELETE, DROP 等修改数据的语句。
"""


@ai_bp.route('/query', methods=['POST'])
def ai_query():
    """
    AI 智能查询接口
    流程：用户提问 -> AI 生成 SQL -> 只读账号执行 SQL -> 返回结果
    """
    user_input = request.form.get('query')
    if not user_input:
        return jsonify({'code': 400, 'msg': '请输入您的问题'})

    try:
        # -----------------------------------
        # 第一步：调用大模型生成 SQL
        # -----------------------------------
        completion = client.chat.completions.create(
            model="qwen-turbo",  # 使用通义千问-Turbo模型
            messages=[
                {'role': 'system', 'content': DB_SCHEMA_PROMPT},
                {'role': 'user', 'content': user_input}
            ],
            temperature=0.5  # 低温度，让 SQL 生成更稳定
        )

        generated_sql = completion.choices[0].message.content
        generated_sql = generated_sql.replace('```sql', '').replace('```', '').strip()

        # 在后台打印生成的 SQL
        print(f" [AI Generated SQL]: {generated_sql}")

        # -----------------------------------
        # 第二步：安全执行 SQL
        # -----------------------------------
        db_reader = DBHelper(user='mall_analyst', password='Audit123!')

        results = db_reader.fetch_all(generated_sql)

        # -----------------------------------
        # 第三步：构建返回结果
        # -----------------------------------
        if not results:
            return jsonify({
                'code': 200,
                'answer': 'AI 已执行查询，但数据库中没有找到匹配的数据。',
                'sql': generated_sql,
                'data': []
            })

        return jsonify({
            'code': 200,
            'answer': f'为您查到了 {len(results)} 条结果：',
            'sql': generated_sql,
            'data': results
        })

    except Exception as e:
        # 捕获所有异常，特别是数据库权限拒绝异常
        error_msg = str(e)
        print(f" [Query Error]: {error_msg}")

        if "Access denied" in error_msg or "command denied" in error_msg:
            return jsonify({
                'code': 403,
                'msg': '安全警告：AI 生成了非法操作语句（如删除/修改），已被数据库自主存取控制系统拦截！'
            })

        return jsonify({'code': 500, 'msg': f'查询出错: {error_msg}'})

@ai_bp.route('/chat')
def chat_page():
    """渲染 AI 聊天页面"""
    return render_template('chat.html')