process.env.NODE_ENV = process.env.NODE_ENV || 'development'

//const SpeedMeasurePlugin = require('speed-measure-webpack-plugin');
const webpackConfig = require('./base')

//const smp = new SpeedMeasurePlugin();
const config = webpackConfig;

module.exports = config;
