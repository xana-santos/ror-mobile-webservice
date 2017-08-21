var UTIL = {
 
  fire : function(func,funcname){

    var funcname = (funcname === undefined) ? 'init' : funcname;
    
	  if (func !== '' && window[func] && typeof window[func][funcname] == 'function'){
	    
      window[func][funcname]();
      
    } 
 
  }, 
 
  loadEvents : function(){
      	
    $.each(document.body.className.split(/\s+/),function(i,classnm){
    
  	  UTIL.fire(classnm);
    
	  }); 
	
    UTIL.fire("common");
	
  } 
};