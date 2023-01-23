package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.def.BooleanVars;
   import engine.math.MathUtil;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import flash.errors.IllegalOperationError;
   
   public class Op_MoveTeleport extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_MoveTeleport",
         "properties":{
            "centerCamera":{
               "type":"boolean",
               "optional":true
            },
            "dist_desired":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      private var centerCamera:Boolean;
      
      private var facing:BattleFacing;
      
      private var dist_desired:int;
      
      private var toLocation:TileLocation;
      
      public function Op_MoveTeleport(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.centerCamera = BooleanVars.parse(param1.params.centerCamera,this.centerCamera);
         this.dist_desired = param1.params.dist_desired;
      }
      
      private function _checkBoardPositioning(param1:int, param2:int) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:TileLocation = null;
         var _loc6_:Tile = null;
         var _loc7_:ITileResident = null;
         var _loc3_:int = 0;
         while(_loc3_ < caster.boardWidth)
         {
            _loc4_ = 0;
            while(_loc4_ < caster.boardLength)
            {
               _loc5_ = TileLocation.fetch(param1 + _loc3_,param2 + _loc4_);
               _loc6_ = board.tiles.getTileByLocation(_loc5_);
               if(!_loc6_)
               {
                  return false;
               }
               _loc7_ = _loc6_.findResident(caster);
               if(_loc7_)
               {
                  return false;
               }
               _loc4_++;
            }
            _loc3_++;
         }
         return true;
      }
      
      private function _visitEdge(param1:int, param2:int, param3:Array) : void
      {
         var _loc4_:TileLocation = null;
         if(this._checkBoardPositioning(param1,param2))
         {
            _loc4_ = TileLocation.fetch(param1,param2);
            param3.push(_loc4_);
         }
      }
      
      private function _findBestTileLocation() : TileLocation
      {
         var sr:TileRect;
         var best_locs:Array;
         var corners:Boolean;
         var lowest:int;
         var count:int;
         var tl:TileLocation = null;
         var top:int = 0;
         var n:int = 0;
         var gg:int = 0;
         var sr_out:TileRect = null;
         var sr_in:TileRect = null;
         var delta:int = 0;
         var d:int = 0;
         if(!this.dist_desired)
         {
            throw new IllegalOperationError("I don\'t think so");
         }
         sr = tile.rect.clone();
         if(this.dist_desired > 1)
         {
            gg = this.dist_desired - 1;
            sr.growUniform(gg);
         }
         best_locs = [];
         corners = true;
         sr.visitAdjacentTileLocations(this._visitEdge,best_locs,true,corners);
         if(!best_locs.length)
         {
            sr_out = sr.clone();
            sr_in = sr.clone();
            delta = 1;
            while(delta < 10)
            {
               sr_out.growUniform(1);
               sr_out.visitAdjacentTileLocations(this._visitEdge,best_locs,true,corners);
               if(best_locs.length)
               {
                  break;
               }
               if(sr_in._localLength > 1 || sr_in._localWidth > 1)
               {
                  sr_in.growUniform(-1);
                  sr_in.visitAdjacentTileLocations(this._visitEdge,best_locs,true,corners);
                  if(best_locs.length)
                  {
                     break;
                  }
               }
               delta++;
            }
         }
         if(!best_locs.length)
         {
            return null;
         }
         best_locs.sort(function(param1:TileLocation, param2:TileLocation):int
         {
            var _loc3_:int = Math.abs(tile.x - param1.x) + Math.abs(tile.y - param1.y);
            var _loc4_:int = Math.abs(tile.x - param2.x) + Math.abs(tile.y - param2.y);
            return _loc3_ - _loc4_;
         });
         lowest = -1;
         count = 0;
         for each(tl in best_locs)
         {
            if(lowest >= 0 && d > lowest)
            {
               break;
            }
            count++;
            d = Math.abs(tile.x - tl.x) + Math.abs(tile.y - tl.y);
            if(lowest < 0)
            {
               lowest = d;
            }
         }
         top = Math.max(0,count - 1);
         n = MathUtil.randomInt(0,top);
         tl = best_locs[n];
         return tl;
      }
      
      override public function execute() : EffectResult
      {
         if(!caster.isSquare)
         {
            return EffectResult.FAIL;
         }
         if(fake)
         {
            return EffectResult.OK;
         }
         if(!this.dist_desired)
         {
            this.toLocation = tile.location;
         }
         else
         {
            this.toLocation = this._findBestTileLocation();
         }
         if(!this.toLocation)
         {
            return EffectResult.FAIL;
         }
         this.facing = caster.facing;
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(fake)
         {
            return;
         }
         logger.debug("Op_MoveTeleport apply");
         if(!this.toLocation)
         {
            logger.error("Op_MoveTeleport no location found " + this);
            return;
         }
         caster.isTeleporting = true;
         caster.setPos(this.toLocation.x,this.toLocation.y);
         if(this.centerCamera)
         {
            caster.centerCameraOnEntity();
         }
         caster.isTeleporting = false;
      }
   }
}
