# taken from https://github.com/mapbox/wgs84/blob/master/index.js

const RADIUS = 6378137
const FLATTENING_DENOM = 298.257223563
const FLATTENING = 1.0 / FLATTENING_DENOM
const POLAR_RADIUS = RADIUS * (1.0 - FLATTENING)