package com.google.analytics.external
{
   import com.google.analytics.debug.DebugConfiguration;
   
   public class AdSenseGlobals extends JavascriptProxy
   {
      
      public static var gaGlobal_js:XML = <script>
            <![CDATA[
                function()
                {
                    try
                    {
                        gaGlobal
                    }
                    catch(e)
                    {
                        gaGlobal = {} ;
                    }
                }
            ]]>
        </script>;
       
      
      private var _gaGlobalVerified:Boolean = false;
      
      public function AdSenseGlobals(param1:DebugConfiguration)
      {
         super(param1);
      }
      
      private function _verify() : void
      {
         if(!this._gaGlobalVerified)
         {
            executeBlock(gaGlobal_js);
            this._gaGlobalVerified = true;
         }
      }
      
      public function get gaGlobal() : Object
      {
         if(!isAvailable())
         {
            return null;
         }
         this._verify();
         return getProperty("gaGlobal");
      }
      
      public function get dh() : String
      {
         if(!isAvailable())
         {
            return null;
         }
         this._verify();
         return getProperty("gaGlobal.dh");
      }
      
      public function get hid() : String
      {
         if(!isAvailable())
         {
            return null;
         }
         this._verify();
         return getProperty("gaGlobal.hid");
      }
      
      public function set hid(param1:String) : void
      {
         if(!isAvailable())
         {
            return;
         }
         this._verify();
         setProperty("gaGlobal.hid",param1);
      }
      
      public function get sid() : String
      {
         if(!isAvailable())
         {
            return null;
         }
         this._verify();
         return getProperty("gaGlobal.sid");
      }
      
      public function set sid(param1:String) : void
      {
         if(!isAvailable())
         {
            return;
         }
         this._verify();
         setProperty("gaGlobal.sid",param1);
      }
      
      public function get vid() : String
      {
         if(!isAvailable())
         {
            return null;
         }
         this._verify();
         return getProperty("gaGlobal.vid");
      }
      
      public function set vid(param1:String) : void
      {
         if(!isAvailable())
         {
            return;
         }
         this._verify();
         setProperty("gaGlobal.vid",param1);
      }
   }
}
