process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const SpeedMeasurePlugin = require('speed-measure-webpack-plugin');
const environment = require('./environment')

const smp = new SpeedMeasurePlugin();
const config = environment.toWebpackConfig();

module.exports = smp.wrap(config);
