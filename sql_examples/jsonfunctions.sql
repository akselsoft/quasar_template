

--- Getting a value from JSON
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

--- Getting JSON from JSON
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


--- Getting JSON Value from JSON Query
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

