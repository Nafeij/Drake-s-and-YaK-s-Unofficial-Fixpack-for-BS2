package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.saga.Saga;
   import engine.scene.SceneControllerConfig;
   import engine.tile.Tile;
   import flash.errors.IllegalOperationError;
   
   public class Action_BattleControllerConfig extends Action
   {
       
      
      public function Action_BattleControllerConfig(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
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
         var _loc2_:SceneControllerConfig = _loc1_.scene.context.sceneControllerConfig;
         var _loc3_:String = def.param;
         var _loc4_:Array = _loc3_.split(";");
         for each(_loc5_ in _loc4_)
         {
            _loc6_ = _loc5_.split("=");
            if(_loc6_.length != 2)
            {
               throw new ArgumentError("invalid token [" + _loc5_ + "] in [" + _loc3_ + "]");
            }
            _loc7_ = String(_loc6_[0]);
            _loc8_ = String(_loc6_[1]);
            this.setFromKvp(_loc1_,_loc7_,_loc8_);
         }
         _loc2_.notify();
         end();
      }
      
      private function extractTile(param1:BattleBoard, param2:String) : Tile
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(Boolean(param2) && param2.charAt(0) == "@")
         {
            param2 = param2.substr(1);
            _loc3_ = param2.split(",");
            _loc4_ = int(_loc3_[0]);
            _loc5_ = int(_loc3_[1]);
            return param1.tiles.getTile(_loc4_,_loc5_);
         }
         return null;
      }
      
      private function setFromKvp(param1:BattleBoard, param2:String, param3:String) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(!param2)
         {
            throw new ArgumentError("No key for kvp");
         }
         var _loc4_:SceneControllerConfig = SceneControllerConfig.instance;
         if(!_loc4_)
         {
            throw new IllegalOperationError("No SceneControllerConfig active");
         }
         switch(param2)
         {
            case "allowMoveTile":
               _loc4_.allowMoveTile = this.extractTile(param1,param3);
               break;
            case "allowWaypointTile":
               _loc4_.allowWaypointTile = this.extractTile(param1,param3);
               break;
            case "allowEntities":
               _loc4_.allowEntities = extractEntities(param3,false);
               break;
            default:
               _loc5_ = Number(param3);
               if(!isNaN(_loc5_) && _loc5_.toString() == param3)
               {
                  _loc4_[param2] = _loc5_;
                  break;
               }
               _loc6_ = int(param3);
               if(_loc6_.toString() == param3)
               {
                  _loc4_[param2] = _loc6_;
                  break;
               }
               _loc4_[param2] = param3;
               break;
         }
      }
   }
}
