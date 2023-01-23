package engine.battle.board.view.phantasm
{
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.ability.phantasm.def.PhantasmDefSprite;
   import engine.battle.ability.phantasm.def.PhantasmTargetMode;
   import engine.battle.ability.phantasm.model.ChainPhantasms;
   import engine.battle.ability.phantasm.model.VfxSequence;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.view.EntityView;
   import engine.resource.IResourceManager;
   import engine.stat.def.StatType;
   import engine.tile.Tile;
   import engine.vfx.VfxLibrary;
   import flash.errors.IllegalOperationError;
   import flash.geom.Point;
   
   public class PhantasmViewSprite extends PhantasmView
   {
      
      private static const CAMERA_DIR:Point = new Point(Math.SQRT1_2,Math.SQRT1_2);
       
      
      public var spriteDef:PhantasmDefSprite;
      
      private var isoSprite:VfxSequenceView;
      
      private var vfx:VfxSequence;
      
      private var smoothing:Boolean;
      
      private var _facing:BattleFacing;
      
      public function PhantasmViewSprite(param1:BattleBoardView, param2:ChainPhantasms, param3:PhantasmDefSprite, param4:Boolean)
      {
         var _loc5_:EntityView = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         super(param1,param2,param3);
         this.smoothing = param4;
         needsUpdate = true;
         needsRemove = true;
         this.spriteDef = param3;
         var _loc6_:BattleAbility = param2.effect.ability as BattleAbility;
         var _loc7_:BattleEntity = _loc6_.caster as BattleEntity;
         var _loc8_:BattleEntity = param2.effect.target as BattleEntity;
         if(this.spriteDef.targetMode == PhantasmTargetMode.CASTER || this.spriteDef.targetMode == PhantasmTargetMode.TILE)
         {
            _loc5_ = boardView.getEntityView(_loc7_);
         }
         else if(param2.effect.target is BattleEntity)
         {
            _loc5_ = boardView.getEntityView(_loc8_);
         }
         else
         {
            _loc5_ = boardView.getEntityView(_loc7_);
         }
         if(_loc5_ == null)
         {
            logger.error("PhantasmViewSprite entity is not in the BattleBoadView");
            return;
         }
         if(!_loc5_.entity.enabled)
         {
            logger.info("PhantasmViewSprite skipping disabled entity " + _loc5_.entity);
            return;
         }
         var _loc9_:VfxLibrary = _loc5_.theVfxLibrary;
         if(param3.useBoardVfxLib && boardView && boardView.board && Boolean(boardView.board.vfxLibrary))
         {
            _loc9_ = boardView.board.vfxLibrary;
         }
         this._facing = null;
         if(this.spriteDef.vfx.oriented == true)
         {
            if(effect.target == effect.ability.caster)
            {
               this._facing = effect.target.facing;
            }
            else
            {
               this._facing = BattleFacing.findFacing(_loc8_.centerX - _loc7_.centerX,_loc8_.centerY - _loc7_.centerY);
            }
         }
         var _loc10_:Number = this.spriteDef.parameter_value;
         if(this.spriteDef.parameter == "damage")
         {
            _loc12_ = param2.effect.getAnnotatedStatChange(StatType.STRENGTH);
            _loc13_ = param2.effect.getAnnotatedStatChange(StatType.ARMOR);
            _loc14_ = Math.max(0,Math.min(1,-_loc12_ / 9));
            _loc15_ = Math.max(0,Math.min(1,-_loc13_ / 5));
            _loc16_ = _loc14_ + _loc15_;
            _loc10_ = _loc16_;
         }
         else if(this.spriteDef.parameter)
         {
            logger.error("Unknown parameter " + this.spriteDef.parameter);
         }
         var _loc11_:IResourceManager = param1.board.resman;
         this.vfx = new VfxSequence(this.spriteDef.vfx,_loc11_,_loc9_,logger,_loc10_,this._facing);
      }
      
      override public function cleanup() : void
      {
         if(this.isoSprite)
         {
            if(this.isoSprite.parent)
            {
               this.isoSprite.parent.removeChild(this.isoSprite);
            }
            this.isoSprite.cleanup();
            this.isoSprite = null;
         }
         if(this.vfx)
         {
            this.vfx.cleanup();
            this.vfx = null;
         }
         super.cleanup();
      }
      
      override public function remove() : void
      {
         if(Boolean(this.vfx) && Boolean(this.vfx.def.loop))
         {
            this.vfx.doEnd();
         }
      }
      
      override public function execute() : void
      {
         var _loc4_:EntityView = null;
         var _loc6_:IBattleEntity = null;
         var _loc7_:* = false;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Tile = null;
         super.execute();
         if(!chain.effect || !this.vfx)
         {
            return;
         }
         var _loc1_:IBattleAbility = chain.effect.ability;
         var _loc2_:BattleEntity = _loc1_.caster as BattleEntity;
         if(!_loc2_)
         {
            throw new IllegalOperationError("no ent?");
         }
         var _loc3_:EntityView = boardView.getEntityView(_loc2_);
         if(_loc3_ == null)
         {
            logger.error("PhantasmViewSprite.execute() entity was not found in the BattleBoadView: " + _loc2_);
            return;
         }
         if(chain.effect.target is BattleEntity)
         {
            _loc4_ = boardView.getEntityView(chain.effect.target as BattleEntity);
         }
         var _loc5_:Number = 0;
         var _loc8_:Number = _loc3_.battleBoardView.units;
         if(this.spriteDef.targetMode == PhantasmTargetMode.CASTER)
         {
            if(this.spriteDef.vfx.oriented == true)
            {
               _loc7_ = this.vfx.flip;
            }
            else
            {
               _loc6_ = !!_loc4_ ? _loc4_.entity : null;
               _loc5_ = _loc3_.height / _loc8_;
               if(!_loc3_.height)
               {
                  _loc5_ = _loc3_.entity.height;
               }
               _loc5_ *= this.spriteDef.height;
            }
            if(this.spriteDef.vfx.attach)
            {
               _loc3_._entityViewVfx.playChildVfxDef(this.spriteDef.vfx,_loc5_);
            }
            else
            {
               this.playSpriteAtWorld(_loc2_.centerX,_loc2_.centerY,_loc6_,_loc5_,_loc7_);
            }
         }
         else if(this.spriteDef.targetMode == PhantasmTargetMode.TARGET)
         {
            if(this.spriteDef.vfx.oriented == true)
            {
               _loc7_ = !this.vfx.flip;
            }
            else
            {
               _loc5_ = _loc4_.height / _loc8_;
               if(!_loc5_)
               {
                  _loc5_ = _loc4_.entity.height;
               }
               _loc5_ *= this.spriteDef.height;
               _loc6_ = _loc3_.entity;
            }
            if(this.spriteDef.vfx.attach)
            {
               _loc4_._entityViewVfx.playChildVfx(this.vfx,_loc5_);
            }
            else
            {
               _loc9_ = Number(_loc4_.entity.centerX);
               _loc10_ = Number(_loc4_.entity.centerY);
               this.playSpriteAtWorld(_loc9_,_loc10_,_loc6_,_loc5_,_loc7_);
            }
         }
         else if(def.targetMode == PhantasmTargetMode.TILE)
         {
            if(_loc1_.targetSet.tiles.length > 0)
            {
               _loc11_ = _loc1_.targetSet.tiles[0];
            }
            else if(_loc1_.targetSet.targets.length > 0)
            {
               _loc11_ = _loc1_.targetSet.targets[0].tile;
            }
            if(_loc11_)
            {
               if(this.spriteDef.vfx.oriented == true)
               {
                  this.playSpriteOnTile(_loc11_,null,0,!this.vfx.flip);
               }
               else
               {
                  this.playSpriteOnTile(_loc11_,_loc3_.entity,0,true);
               }
            }
         }
      }
      
      private function playSpriteOnTile(param1:Tile, param2:IBattleEntity, param3:Number, param4:Boolean) : void
      {
         var _loc5_:Point = !!this.spriteDef.vfx.offset ? this.spriteDef.vfx.offset : new Point(0,0);
         var _loc6_:Point = new Point(param1.centerX + _loc5_.x,param1.centerY + _loc5_.y);
         this.playSpriteAtWorld(_loc6_.x,_loc6_.y,param2,param3,param4);
      }
      
      private function playSpriteAtWorld(param1:Number, param2:Number, param3:IBattleEntity, param4:Number, param5:Boolean = false) : void
      {
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Point = null;
         var _loc6_:String = this.vfx.depth;
         var _loc7_:IsoScene = boardView.isoScenes.getIsoScene(_loc6_);
         if(!_loc7_)
         {
            logger.error("No such depth [" + this.vfx.def.depth + "] for vfx " + this.vfx);
            return;
         }
         var _loc8_:Number = boardView.units;
         var _loc9_:Number = 1;
         if(this.spriteDef.rotate == true)
         {
            _loc10_ = !!param3 ? Number(param3.centerX) : 0;
            _loc11_ = !!param3 ? Number(param3.centerY) : 0;
            _loc12_ = new Pt(param1 - _loc10_,param2 - _loc11_,0);
            if(_loc12_.x > _loc12_.y)
            {
               _loc9_ *= -1;
            }
         }
         if(param5)
         {
            _loc9_ *= -1;
         }
         this.isoSprite = new VfxSequenceView(this.vfx,logger,this.smoothing);
         this.isoSprite.container.scaleX *= _loc9_;
         this.isoSprite.moveTo(param1 * _loc8_,param2 * _loc8_,param4 * _loc8_);
         _loc7_.addChild(this.isoSprite);
         if((this.spriteDef.color & 16777215) != 16777215)
         {
            this.isoSprite.container.color = this.spriteDef.color;
         }
         if(this.spriteDef.alpha != 1)
         {
            this.isoSprite.container.alpha = this.spriteDef.alpha;
         }
      }
      
      override public function update(param1:int) : Boolean
      {
         if(this.vfx)
         {
            this.vfx.update(param1);
            if(this.isoSprite)
            {
               this.isoSprite.update(param1);
            }
            if(this.vfx.complete)
            {
               return false;
            }
            return true;
         }
         return false;
      }
   }
}
