/* ============================================================
 * Bootstrap: rowlink.js v3.1.3
 * http://jasny.github.io/bootstrap/javascript/#rowlink
 * ============================================================
 * Copyright 2012-2014 Arnold Daniels
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================ */
+function(t){"use strict";var n=function(i,e){this.$element=t(i),this.options=t.extend({},n.DEFAULTS,e),this.$element.on("click.bs.rowlink","td:not(.rowlink-skip)",t.proxy(this.click,this))};n.DEFAULTS={target:"a"},n.prototype.click=function(n){var i=t(n.currentTarget).closest("tr").find(this.options.target)[0];if(t(n.target)[0]!==i)if(n.preventDefault(),i.click)i.click();else if(document.createEvent){var e=document.createEvent("MouseEvents");e.initMouseEvent("click",!0,!0,window,0,0,0,0,0,!1,!1,!1,!1,0,null),i.dispatchEvent(e)}};var i=t.fn.rowlink;t.fn.rowlink=function(i){return this.each(function(){var e=t(this),o=e.data("bs.rowlink");o||e.data("bs.rowlink",o=new n(this,i))})},t.fn.rowlink.Constructor=n,t.fn.rowlink.noConflict=function(){return t.fn.rowlink=i,this},t(document).on("click.bs.rowlink.data-api",'[data-link="row"]',function(n){if(0===t(n.target).closest(".rowlink-skip").length){var i=t(this);i.data("bs.rowlink")||(i.rowlink(i.data()),t(n.target).trigger("click.bs.rowlink"))}})}(window.jQuery);