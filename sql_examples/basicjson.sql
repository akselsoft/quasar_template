SELECT *
FROM Customers
FOR JSON AUTO


    SELECT *
    FROM Customers
    FOR JSON PATH, ROOT('Customers')

        SELECT CustomerName,
            Active,
            Location,
            CountryId as 'Country.Id',
            English as 'Country.English'
        FROM Customers A
            inner join countries b
            on a.countryid=b.id
        FOR JSON PATH

