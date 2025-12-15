import pymysql


class DBHelper:
    def __init__(self, user=None, password=None):
        self.host = 'localhost'
        self.db = 'mall_b2c'
        self.charset = 'utf8mb4'

        # ========================================================
        # 🔑 账号配置 (请确认您的 root 密码)
        # ========================================================

        # 默认使用管理员账号 (用于购物车、下单、登录)
        default_user = 'root'
        default_password = 'shisannian1223'

        # 逻辑：如果外部传了账号(比如AI模块)，就用外部的；否则用默认管理员
        if user:
            self.user = user
            self.password = password
        else:
            self.user = default_user
            self.password = default_password

    def get_connection(self):
        """获取数据库连接"""
        return pymysql.connect(
            host=self.host,
            user=self.user,
            password=self.password,
            database=self.db,
            charset=self.charset,
            cursorclass=pymysql.cursors.DictCursor
        )

    def fetch_all(self, sql, params=None):
        """查询多条记录 (SELECT)"""
        conn = self.get_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute(sql, params)
                return cursor.fetchall()
        finally:
            conn.close()

    def fetch_one(self, sql, params=None):
        """查询单条记录 (SELECT)"""
        conn = self.get_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute(sql, params)
                return cursor.fetchone()
        finally:
            conn.close()

    def execute_update(self, sql, params=None):
        """
        执行增删改 (INSERT, UPDATE, DELETE)
        会自动提交事务
        """
        conn = self.get_connection()
        try:
            with conn.cursor() as cursor:
                row = cursor.execute(sql, params)
                conn.commit()  # 提交事务
                return row
        except Exception as e:
            conn.rollback()  # 出错回滚
            raise e
        finally:
            conn.close()