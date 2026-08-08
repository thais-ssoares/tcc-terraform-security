import os

def handler(event, context):
    # ❌ lendo variável sensível (hardcoded no Terraform)
    db_password = os.environ.get("DB_PASSWORD")

    return {
        "statusCode": 200,
        "body": f"Senha do banco: {db_password}"  # ❌ vazamento de segredo
    }
