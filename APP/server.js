require('dotenv').config({ path: '.env' })

const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const port = process.env.PORT;

app.set('view engine', 'ejs')
app.use(
    bodyParser.urlencoded({
        extended: true,
    })
)

app.use(bodyParser.raw());
app.use(express.static("public"));


app.listen(port, () => {
    console.log(`App is running on port ${port}.`)
})