(function(){var e;e=jQuery,e.fn.isogrid=function(t){var n;return n={html:"",itemSelector:".item",layoutMode:"masonry",data:null},t=e.extend(n,t),this.each(function(){var n;return n=e(t.html),e(this).isotope()!==null&&e(this).isotope("destroy"),e(this).isotope({itemSelector:t.itemSelector,layoutMode:t.layoutMode}),e(this).isotope("insert",n),e(t.itemSelector).bind("click",function(n){return e(t.itemSelector).each(function(t){return e(this).removeClass("selected")}),e(this).addClass("visited"),e(this).addClass("selected")}),e(t.itemSelector).bind("click",t.item_clickHandler),e(t.itemSelector+":odd").each(function(){return e(this).addClass("item-odd")})})}}).call(this);