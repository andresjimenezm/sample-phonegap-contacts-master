var $loader = $('.preloader'),$sideBar = $('.sidebar'),$menu = $sideBar.children('button'),$sideSub = $('.sidebar-sub'),
	$button = $('.in-basic > button'),$tabs = $sideSub.children('section'),$optLi = $('.options-list > li'),
	$colorLi = $('.themes > li'),$img = $('.images').children('li'),$tables = $('.tables').children('li'),
	$textLi = $('.text-list > li'),$transLi = $('.transition > li'),$fonts = $('.fonts > li'),
	$btn = $('.in-basic').children('button'),$slides = $('.slides').children('section'),
	$prester = $('.dash'),$page = $('.slides').html(),$anim = 'moveFromLeft',$all = $('.inner > *'),
	$current = $('.pres > .inner'),$currentTheme = 'greyblue',$currentFont = 'Century',
	$con = $('.controller'), cur = 0

var prester = {
    ready: function(){
        this.setUp()
		this.controls()
        this.show()
    },
    show: function(){
        window.setTimeout(function(){$loader.addClass('trans')},5000)
        window.setTimeout(function(){$loader.addClass('hidden'); prester.on($sideBar)},5400)
    },
    setUp: function(){
		this.off()
        $($sideBar.children('button')).each(function(){$(this).addClass(' button fa')})
        $btn.each(function(){$(this).addClass(' btn2 float fa2')})
        $optLi.each(function(){$(this).addClass($(this).data('attr'))})
		$img.each(function(){$(this).attr('style','background-repeat:no-repeat;background-image:url(img/'+$(this).data('attr')+')')})
		$tables.each(function(){$(this).html('<table border=1><tr><td></td><td></td><td></td></tr><tr><td></td><td></td><td></td></tr><tr><td></td><td></td><td></td></tr></table>')})
        $textLi.each(function(){$(this).html('<h4>'+$(this).data('attr')+'</h4><span>type</span>')})
        $transLi.each(function(){$(this).html('<h4>'+$(this).data('attr'))})
		$prester.addClass($currentTheme)
		$slides = $('.slides').children('section')
		$('.costumize').hide()
		prester.storyControl()
    },
    off:function(){
		$tabs.each(function(){$(this).removeClass('active').addClass('inactive')})
	},
	on:function(x){
		this.off();$(x).removeClass('inactive').addClass('active')
	},
	check:function(x){
		$(x).hasClass('active')?this.off():this.on(x)
	},
	update : function(){
		$all = $('.inner > *')
		$all.each(function(){$(this).tap(function(){$current.removeClass('current').removeAttr('contenteditable');
		$all.each(function(){$(this).doubleTap(function(){$('.costumize').show()})})
		$current = $(this);
	    $current.addClass('current')})})		
		$all.each(function(){$(this).tap(function(){$(this).attr('contenteditable','true')})})
		prester.storyControl()
	},
	addSlide : function(){
		var $temp = $('.pres')
		$temp.attr('class','prev').after($page)
		$('.pres').addClass('moveFromRight');
		$('.prev:last').addClass('moveToLeft').attr('style','display:block');
				
		this.update()
	},
	deleteSlide : function(){
		$('.pres').addClass('scaleDown')
		$('.pres').remove()
		$('.prev:last').attr('class','pres')
		$('.pres').addClass('moveFromLeft')
	},
	addBullet:function(){
		$('.pres > .inner').append('<ul><li>Text Here</li><li></li></ul>');
		prester.update();
	},	
	addImage:function(x){
		$('.pres > .inner').append('<img/>');
		var $temp = $('.inner > img:last');
		$temp.attr('src','img/'+x.data('attr'));
		$temp.attr('style','position:absolute');
		this.update();
	},	
	addTable:function(x){
		$('.pres > .inner').append('<table border=1><tr><td></td><td></td><td></td></tr><tr><td></td><td></td><td></td></tr><tr><td></td><td></td><td></td></tr></table>');
		var $temp = $('.inner > table:last');
		$temp.attr('class',x.data('attr'));
		this.update();
	},	
	changeTheme:function(x){
		$prester.addClass($(x).data('attr')).removeClass($currentTheme)
		$textLi.addClass($(x).data('attr')).removeClass($currentTheme)	
		$currentTheme = $(x).data('attr')
	},
	changeFont:function(x){
		$prester.addClass($(x).data('attr')).removeClass($currentFont)
		$currentFont = $(x).data('attr')
	},
	changeFontSize:function(x){
		var $temp = $('#size').val()
		$current.attr('style','font-size:'+$temp+'em')
	},
	changeWidth:function(x){
		var $temp = $('#width').val()
		$current.attr('style','height:'+$temp+'em')
	},
	changeRotate:function(x){
		var $temp = $('#degree').val()
		$current.attr('style','-webkit-transform:rotate('+$temp+'deg)')
	},		
	changeTrans:function(x,y){
		$entrance = x;
		$exit = y;
	},
	changeAttr:function(x){
		$current.hasClass(x)? $current.removeClass(x):
		$current.addClass(x)		
	},
	storyControl:function(){
		$slides = $('.slides').children('section')
		for(i=0;i<$slides.length;i++){
			if($($slides[i]).hasClass('pres')){cur = i}
			if(cur==0){$('.arrowLeft').attr('style','opacity:0')}
			else{$('.arrowLeft').attr('style','opacity:1')}
			if(cur==$slides.length-1){$('.arrowRight').attr('style','opacity:0')}
			else{$('.arrowRight').attr('style','opacity:1')}
		}
	},										
	controls:function(){
		this.update()
		$('#close').tap(function(){$('.notification').hide()})
		$menu.each(function(){$(this).tap(function(){prester.check($(this).data('tab'))})})
		$btn.each(function(){$(this).tap(function(){var $tmp = $(this).data('attr');prester.changeAttr($tmp)})})		
		$prester.tap(function(){prester.off()})
		$all.tap(function(){$('.costumize').hide()})
		$tabs.swipeLeft(function(){prester.off()})
		$('.fa-plus-circle').tap(function(){prester.addSlide()})
		$('.in-basic > .fa-eraser').tap(function(){prester.deleteSlide()})
		$('.fa-list-ul').tap(function(){prester.addBullet()})				
		$tables.each(function(){$(this).tap(function(){prester.addTable($(this))})})
		$img.each(function(){$(this).tap(function(){prester.addImage($(this))})})
		$colorLi.each(function(){$(this).tap(function(){prester.changeTheme($(this))})})
		$fonts.each(function(){$(this).tap(function(){prester.changeFont($(this))})})
		$('.costumize').doubleTap(function(){$('.costumize').hide()})
		$('.arrowLeft').tap(function(){
			prester.storyControl()	
			for(i=0;i<$slides.length;i++){
					if(i<cur-1){
						$($slides[i]).attr('class','prev')
						}
					if(i==cur-1){
						$($slides[i]).attr('class','pres')
						}
					if(i==cur){
						}						
					if(i>=cur && cur>0){
						$($slides[i]).attr('class','next')
						}
						$($slides[i]).attr('style','')
				}
				$('.pres').addClass('moveFromRight');
				$('.next:first').addClass('scaleDown').attr('style','display:block');
				$('.next').tap(function(){$('.next').hide()});
				prester.update();
			})
		$('.arrowRight').tap(function(){
			prester.storyControl()
			for(i=0;i<$slides.length;i++){
					if(i<=cur && i<$slides.length-1){
						$($slides[i]).attr('class','prev')
						}
					if(i==cur+1){
						$($slides[i]).attr('class','pres')
						}
					if(i>cur+1 && i<$slides.length-1){
						$($slides[i]).attr('class','next')
						}
						$($slides[i]).attr('style','')						
				}			
				$('.pres').addClass('moveFromLeft');
				$('.prev:last').addClass('scaleDown').attr('style','display:block');
				prester.update();
			})		
	}
};