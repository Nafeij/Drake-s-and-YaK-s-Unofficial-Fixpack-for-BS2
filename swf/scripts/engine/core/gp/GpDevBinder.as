package engine.core.gp
{
   import flash.utils.Dictionary;
   
   public class GpDevBinder
   {
      
      public static var instance:GpDevBinder = new GpDevBinder();
       
      
      private var binds:Dictionary;
      
      public function GpDevBinder()
      {
         this.binds = new Dictionary();
         super();
      }
      
      private function makeKey(param1:GpControlButton, param2:GpControlButton, param3:int) : String
      {
         return (!!param1 ? param1 : "NO") + "+" + param2 + "_" + param3;
      }
      
      public function bind(param1:GpControlButton, param2:GpControlButton, param3:int, param4:Function, param5:Array = null) : void
      {
         var _loc6_:String = this.makeKey(param1,param2,param3);
         var _loc7_:Array = this.binds[_loc6_];
         if(!_loc7_)
         {
            _loc7_ = [];
            this.binds[_loc6_] = _loc7_;
         }
         _loc7_.push({
            "func":param4,
            "args":param5
         });
      }
      
      public function unbind(param1:Function) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         for each(_loc2_ in this.binds)
         {
            _loc3_ = _loc2_.length - 1;
            while(_loc3_ >= 0)
            {
               _loc4_ = _loc2_[_loc3_];
               if(_loc4_.func == param1)
               {
                  _loc2_.splice(_loc3_,1);
               }
               _loc3_--;
            }
         }
      }
      
      public function notifyBind(param1:GpControlButton, param2:GpControlButton, param3:int) : void
      {
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc8_:Function = null;
         var _loc9_:Array = null;
         var _loc4_:String = this.makeKey(param1,param2,param3);
         var _loc5_:Array = this.binds[_loc4_];
         if(_loc5_)
         {
            _loc6_ = _loc5_.length - 1;
            while(_loc6_ >= 0)
            {
               _loc7_ = _loc5_[_loc6_];
               _loc8_ = _loc7_.func;
               _loc9_ = _loc7_.args;
               if(_loc8_ != null)
               {
                  _loc8_.apply(null,_loc9_);
                  return;
               }
               _loc6_--;
            }
         }
      }
   }
}
