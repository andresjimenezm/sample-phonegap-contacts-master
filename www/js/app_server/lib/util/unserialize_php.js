function unserialize_php(e){var t=this,n=function(e){var t=e.charCodeAt(0);return t<128?0:t<2048?1:2},r=function(e,n,r,i){throw new t.window[e](n,r,i)},i=function(e,t,n){var i=2,s=[],o=e.slice(t,t+1);while(o!=n)i+t>e.length&&r("Error","Invalid"),s.push(o),o=e.slice(t+(i-1),t+i),i+=1;return[s.length,s.join("")]},s=function(e,t,r){var i,s,o;o=[];for(i=0;i<r;i++)s=e.slice(t+(i-1),t+i),o.push(s),r-=n(s);return[o.length,o.join("")]},o=function(e,t){var n,u,a,f,l,c,h,p,d,v,m,g,y,b,w,E=0,S=function(e){return e};t||(t=0),n=e.slice(t,t+1).toLowerCase(),u=t+2;switch(n){case"i":S=function(e){return parseInt(e,10)},c=i(e,u,";"),E=c[0],l=c[1],u+=E+1;break;case"b":S=function(e){return parseInt(e,10)!==0},c=i(e,u,";"),E=c[0],l=c[1],u+=E+1;break;case"d":S=function(e){return parseFloat(e)},c=i(e,u,";"),E=c[0],l=c[1],u+=E+1;break;case"n":l=null;break;case"s":h=i(e,u,":"),E=h[0],p=h[1],u+=E+2,c=s(e,u+1,parseInt(p,10)),E=c[0],l=c[1],u+=E+2,E!=parseInt(p,10)&&E!=l.length&&r("SyntaxError","String length mismatch");break;case"a":l={},a=i(e,u,":"),E=a[0],f=a[1],u+=E+2;for(d=0;d<parseInt(f,10);d++)m=o(e,u),g=m[1],v=m[2],u+=g,y=o(e,u),b=y[1],w=y[2],u+=b,l[v]=w;u+=1;break;default:r("SyntaxError","Unknown / Unhandled data type(s): "+n)}return[n,u-t,S(l)]};return o(e+"",0)[2]};