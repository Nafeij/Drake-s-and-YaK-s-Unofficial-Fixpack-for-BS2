package game.gui.page
{
   public class GuiCreditsSectionConfig
   {
       
      
      public var cols:int = 1;
      
      public var aligns:Array;
      
      public var isbmp:Boolean;
      
      public function GuiCreditsSectionConfig()
      {
         super();
      }
      
      public function decode(param1:String) : GuiCreditsSectionConfig
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         if(param1 == "bmp")
         {
            this.cols = 1;
            this.isbmp = true;
            return this;
         }
         if(param1)
         {
            this.cols = int(param1.charAt(0));
            if(param1.length > 1)
            {
               _loc2_ = param1.substr(1);
               _loc3_ = _loc2_.split(" ");
               for each(_loc4_ in _loc3_)
               {
                  _loc5_ = _loc4_.split("=");
                  _loc6_ = String(_loc5_[0]);
                  _loc7_ = null;
                  if(_loc5_.length > 1)
                  {
                     _loc7_ = String(_loc5_[1]);
                  }
                  this._processKvp(_loc6_,_loc7_);
               }
            }
         }
         return this;
      }
      
      private function _processKvp(param1:String, param2:String) : void
      {
         switch(param1)
         {
            case "align":
               if(param2)
               {
                  this.aligns = param2.split(",");
               }
         }
      }
      
      public function getAlign(param1:int) : String
      {
         if(!this.aligns || param1 >= this.aligns.length)
         {
            return null;
         }
         return this.aligns[param1];
      }
   }
}
