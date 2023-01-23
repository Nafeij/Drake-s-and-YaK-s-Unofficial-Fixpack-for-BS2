package com.google.analytics.external
{
   import com.google.analytics.debug.DebugConfiguration;
   import flash.external.ExternalInterface;
   import flash.system.Capabilities;
   
   public class JavascriptProxy
   {
      
      public static var hasProperty_js:XML = <script>
                <![CDATA[
                    function( path )
                    {
                        var paths;
                        if( path.indexOf(".") > 0 )
                        {
                            paths = path.split(".");
                        }
                        else
                        {
                            paths = [path];
                        }
                        var target = window ;
                        var len    = paths.length ;
                        for( var i = 0 ; i < len ; i++ )
                        {
                            target = target[ paths[i] ] ;
                        }
                        if( target )
                        {
                            return true;
                        }
                        else
                        {
                            return false;
                        }
                    }
                ]]>
            </script>;
      
      public static var setProperty_js:XML = <script>
                <![CDATA[
                    function( path , value )
                    {
                        var paths;
                        var prop;
                        if( path.indexOf(".") > 0 )
                        {
                            paths = path.split(".");
                            prop  = paths.pop() ;
                        }
                        else
                        {
                            paths = [];
                            prop  = path;
                        }
                        var target = window ;
                        var len    = paths.length ;
                        for( var i = 0 ; i < len ; i++ )
                        {
                            target = target[ paths[i] ] ;
                        }
                        
                        target[ prop ] = value ;
                    }
                ]]>
            </script>;
      
      public static var setPropertyRef_js:XML = <script>
                <![CDATA[
                    function( path , target )
                    {
                        var paths;
                        var prop;
                        if( path.indexOf(".") > 0 )
                        {
                            paths = path.split(".");
                            prop  = paths.pop() ;
                        }
                        else
                        {
                            paths = [];
                            prop  = path;
                        }
                        alert( "paths:"+paths.length+", prop:"+prop );
                        var targets;
                        var name;
                        if( target.indexOf(".") > 0 )
                        {
                            targets = target.split(".");
                            name    = targets.pop();
                        }
                        else
                        {
                            targets = [];
                            name    = target;
                        }
                        alert( "targets:"+targets.length+", name:"+name );
                        var root = window;
                        var len  = paths.length;
                        for( var i = 0 ; i < len ; i++ )
                        {
                            root = root[ paths[i] ] ;
                        }
                        var ref   = window;
                        var depth = targets.length;
                        for( var j = 0 ; j < depth ; j++ )
                        {
                            ref = ref[ targets[j] ] ;
                        }
                        root[ prop ] = ref[name] ;
                    }
                ]]>
            </script>;
       
      
      private var _debug:DebugConfiguration;
      
      private var _notAvailableWarning:Boolean = true;
      
      public function JavascriptProxy(param1:DebugConfiguration)
      {
         super();
         this._debug = param1;
      }
      
      public function call(param1:String, ... rest) : *
      {
         var output:String = null;
         var functionName:String = param1;
         var args:Array = rest;
         if(this.isAvailable())
         {
            try
            {
               if(this._debug.javascript && this._debug.verbose)
               {
                  output = "";
                  output = "Flash->JS: " + functionName;
                  output += "( ";
                  if(args.length > 0)
                  {
                     output += args.join(",");
                  }
                  output += " )";
                  this._debug.info(output);
               }
               args.unshift(functionName);
               return ExternalInterface.call.apply(ExternalInterface,args);
            }
            catch(e:SecurityError)
            {
               if(_debug.javascript)
               {
                  _debug.warning("ExternalInterface is not allowed.\nEnsure that allowScriptAccess is set to \"always\" in the Flash embed HTML.");
               }
            }
            catch(e:Error)
            {
               if(_debug.javascript)
               {
                  _debug.warning("ExternalInterface failed to make the call\nreason: " + e.message);
               }
            }
         }
         return null;
      }
      
      public function executeBlock(param1:String) : void
      {
         var data:String = param1;
         if(this.isAvailable())
         {
            try
            {
               ExternalInterface.call(data);
            }
            catch(e:SecurityError)
            {
               if(_debug.javascript)
               {
                  _debug.warning("ExternalInterface is not allowed.\nEnsure that allowScriptAccess is set to \"always\" in the Flash embed HTML.");
               }
            }
            catch(e:Error)
            {
               if(_debug.javascript)
               {
                  _debug.warning("ExternalInterface failed to make the call\nreason: " + e.message);
               }
            }
         }
      }
      
      public function getProperty(param1:String) : *
      {
         return this.call(param1 + ".valueOf");
      }
      
      public function getPropertyString(param1:String) : String
      {
         return this.call(param1 + ".toString");
      }
      
      public function hasProperty(param1:String) : Boolean
      {
         return this.call(hasProperty_js,param1);
      }
      
      public function isAvailable() : Boolean
      {
         var _loc1_:Boolean = ExternalInterface.available;
         if(_loc1_ && Capabilities.playerType == "External")
         {
            _loc1_ = false;
         }
         if(!_loc1_ && this._debug.javascript && this._notAvailableWarning)
         {
            this._debug.warning("ExternalInterface is not available.");
            this._notAvailableWarning = false;
         }
         return _loc1_;
      }
      
      public function setProperty(param1:String, param2:*) : void
      {
         this.call(setProperty_js,param1,param2);
      }
      
      public function setPropertyByReference(param1:String, param2:String) : void
      {
         this.call(setPropertyRef_js,param1,param2);
      }
   }
}
