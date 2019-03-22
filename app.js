let queryBuilder = require('./queryBuilder');
module.exports = (req, res) => {

    const {EmployeeID} = req.user;
    const params = req.query;

    let sql = queryBuilder(params, EmployeeID);

    console.log(sql);
    const db = req.dbConnection;
    db.query(sql, (err, rows) => {
        if (err) {
            res.status(400).json({err})
        } else {

            if (params.helpgte || params.helplte) {

                rows = rows.filter(row => {
                    /**
                     * When we have just GTE param we find all records where helpful is grater than param OR less than -1
                     * When we have just LTE param we find all records where helpful is less than param OR grated than 101
                     * When we have two params we find all record in our values
                     */
                    return (row.helpfulRate >= (params.helpgte || 101))
                        || (row.helpfulRate <= (params.helplte || -1))
                        && row.helpfulRate !== null
                });
            }
            res.json(rows)

        }
    });
};

