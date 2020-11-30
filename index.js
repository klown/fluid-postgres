/* eslint-env node */
"use strict";
var fluid = require("infusion");

fluid.module.register("fluid-postgres", __dirname, require);

require("./src/js/postGresOperations");

fluid.registerNamespace("fluid.postgres");
