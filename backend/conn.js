const mongoose = require('mongoose')

const URL = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/travelmemory'

mongoose.connect(URL, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
mongoose.Promise = global.Promise

const db = mongoose.connection
db.on('error', console.error.bind(console, 'DB ERROR: '))
db.once('open', () => console.log(`MongoDB connected successfully to ${URL}`))

module.exports = {db, mongoose}