from fastmcp import FastMCP
import pymysql
import json
from decimal import Decimal
from datetime import datetime, date

# 创建 MCP 服务器对象
mcp = FastMCP(
    "标题:我自己的一个给智能体使用的mcp服务2",
    "描述:支持数据库访问、售后规则查询、退换货说明、人工客服兜底"
)

def get_conn():
    """
    创建 MySQL 连接
    """
    return pymysql.connect(
        host="localhost",
        port=3306,
        user="root",
        password="root",
        database="chatbi",
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=False
    )

def to_json(data):
    """
    把查询结果转成 JSON 字符串，方便智能体读取
    """
    def converter(obj):
        if isinstance(obj, Decimal):
            return float(obj)
        if isinstance(obj, (datetime, date)):
            return obj.strftime("%Y-%m-%d %H:%M:%S")
        return str(obj)

    return json.dumps(data, ensure_ascii=False, default=converter)

# ====================================
# 1. 通用数据库工具：直接执行 SQL
# ====================================
@mcp.tool
def get_data_base(sql: str):
    """
    获取数据库信息 / 执行 SQL

    参数:
        - sql: 字符串，传入 SQL 语句，mysql 的版本是 5.7

    返回:
        - 查询类 SQL：返回查询结果
        - 执行类 SQL：返回执行状态
    """
    print("获取数据库信息的工具函数被调用了....", sql)

    conn = None
    cursor = None

    try:
        conn = get_conn()
        cursor = conn.cursor()

        sql_strip = sql.strip()
        sql_lower = sql_strip.lower()

        affected_rows = cursor.execute(sql_strip)

        # 查询类 SQL
        if sql_lower.startswith(("select", "show", "desc", "describe", "explain")):
            result = cursor.fetchall()
            return to_json({
                "success": True,
                "type": "query",
                "row_count": len(result),
                "data": result
            })

        # 非查询类 SQL
        conn.commit()
        return to_json({
            "success": True,
            "type": "execute",
            "affected_rows": affected_rows,
            "message": "SQL 执行成功"
        })

    except Exception as e:
        if conn:
            conn.rollback()
        return to_json({
            "success": False,
            "error": str(e)
        })

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# ====================================
# 2. 查询售后规则
# ====================================
@mcp.tool
def get_after_sales_policy(policy_type: str):
    """
    查询售后规则

    参数:
        - policy_type: return / exchange / refund / damage / manual

    返回:
        对应售后规则
    """
    print("售后规则工具被调用了....", policy_type)

    conn = None
    cursor = None

    try:
        conn = get_conn()
        cursor = conn.cursor()

        sql = """
        SELECT policy_type, title, content, updated_at
        FROM after_sales_policy
        WHERE policy_type = %s
        LIMIT 1
        """
        cursor.execute(sql, (policy_type,))
        result = cursor.fetchone()

        if not result:
            return to_json({
                "success": False,
                "message": f"未找到类型为 {policy_type} 的售后规则"
            })

        return to_json({
            "success": True,
            "data": result
        })

    except Exception as e:
        return to_json({
            "success": False,
            "error": str(e)
        })

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# ====================================
# 3. 创建人工客服工单
# ====================================
@mcp.tool
def create_human_service_ticket(username: str, contact: str, service_type: str, description: str):
    """
    创建人工客服工单

    参数:
        - username: 用户姓名
        - contact: 联系方式
        - service_type: 服务类型，例如 退货/换货/退款/商品破损/人工咨询
        - description: 问题描述

    返回:
        工单编号及状态
    """
    print("人工客服工单工具被调用了....", username, contact, service_type)

    conn = None
    cursor = None

    try:
        conn = get_conn()
        cursor = conn.cursor()

        ticket_id = "TICKET" + datetime.now().strftime("%Y%m%d%H%M%S")

        sql = """
        INSERT INTO human_service_ticket
        (ticket_id, username, contact, service_type, description, status, created_at, updated_at)
        VALUES (%s, %s, %s, %s, %s, %s, NOW(), NOW())
        """
        cursor.execute(sql, (
            ticket_id,
            username,
            contact,
            service_type,
            description,
            "待处理"
        ))
        conn.commit()

        return to_json({
            "success": True,
            "message": "人工客服工单已创建",
            "ticket_id": ticket_id,
            "status": "待处理"
        })

    except Exception as e:
        if conn:
            conn.rollback()
        return to_json({
            "success": False,
            "error": str(e)
        })

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# ====================================
# 4. 查询人工客服工单状态
# ====================================
@mcp.tool
def query_human_service_ticket(ticket_id: str):
    """
    查询人工客服工单状态

    参数:
        - ticket_id: 工单编号

    返回:
        工单详情
    """
    print("人工客服工单状态查询工具被调用了....", ticket_id)

    conn = None
    cursor = None

    try:
        conn = get_conn()
        cursor = conn.cursor()

        sql = """
        SELECT ticket_id, username, contact, service_type, description, status, created_at, updated_at
        FROM human_service_ticket
        WHERE ticket_id = %s
        LIMIT 1
        """
        cursor.execute(sql, (ticket_id,))
        result = cursor.fetchone()

        if not result:
            return to_json({
                "success": False,
                "message": f"未查询到工单 {ticket_id}"
            })

        return to_json({
            "success": True,
            "data": result
        })

    except Exception as e:
        return to_json({
            "success": False,
            "error": str(e)
        })

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

if __name__ == '__main__':
    print("启动mcp服务器: http://localhost:8082/mcp")
    mcp.run(transport="streamable-http", port=8082)