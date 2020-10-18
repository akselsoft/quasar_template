
SELECT JSON_QUERY(
'{
        "CustomerName": "Narwhal",
        "Active": true,
        "Location": "Canadaland",
        "Country": {
            "Id": 1,
            "English": "Canada"
        }
    }','$."Country"')


SELECT JSON_Value(
'{
        "CustomerName": "Narwhal",
        "Active": true,
        "Location": "Canadaland",
        "Country": {
            "Id": 1,
            "English": "Canada"
        }
    }','$."CustomerName"')


SELECT JSON_VALUE(JSON_QUERY(
'{
        "CustomerName": "Narwhal",
        "Active": true,
        "Location": "Canadaland",
        "Country": {
            "Id": 1,
            "English": "Canada"
        }
    }','$."Country"'),'$."Id"')

