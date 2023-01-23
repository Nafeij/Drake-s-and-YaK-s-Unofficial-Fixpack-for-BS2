package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.gui.BattleHudConfig;
   import engine.saga.Saga;
   
   public class Action_BattleHudConfig extends Action
   {
       
      
      public function Action_BattleHudConfig(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc1_:BattleBoard = saga.getBattleBoard();
         if(!_loc1_)
         {
            end();
            return;
         }
         var _loc2_:BattleHudConfig = BattleHudConfig.instance;
         var _loc3_:String = def.param;
         if(_loc3_)
         {
            _loc4_ = _loc3_.split(";");
            for each(_loc5_ in _loc4_)
            {
               _loc6_ = _loc5_.split("=");
               if(_loc6_.length != 2)
               {
                  throw new ArgumentError("invalid token [" + _loc5_ + "] in [" + _loc3_ + "]");
               }
               _loc7_ = _loc6_[0];
               _loc8_ = _loc6_[1];
               this.setFromKvp(_loc1_,_loc7_,_loc8_);
            }
         }
         _loc2_.notify();
         end();
      }
      
      private function setFromKvp(param1:BattleBoard, param2:String, param3:String) : void
      {
         var _loc4_:BattleHudConfig = BattleHudConfig.instance;
         if(!_loc4_.hasOwnProperty(param2))
         {
            throw new ArgumentError("No such config key [" + param2 + "]");
         }
         if(_loc4_[param2] is Boolean)
         {
            _loc4_[param2] = param3 && param3 != "0";
         }
         else
         {
            _loc4_[param2] = param3;
         }
      }
   }
}
