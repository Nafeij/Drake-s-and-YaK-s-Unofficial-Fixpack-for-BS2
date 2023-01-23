package game.cfg
{
   import engine.anim.def.AnimLibrary;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.view.EntityView;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.util.Enum;
   import engine.core.util.StringUtil;
   import flash.geom.Point;
   
   public class AnimLibraryShellCmdManager extends ShellCmdManager
   {
       
      
      private var config:GameConfig;
      
      public var library:AnimLibrary;
      
      public function AnimLibraryShellCmdManager(param1:GameConfig)
      {
         super(param1.logger);
         this.config = param1;
         add("offset",this.shellFuncOffset);
      }
      
      private function shellFuncOffset(param1:CmdExec) : void
      {
         var _loc3_:BattleFacing = null;
         var _loc6_:Point = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:BattleBoardView = null;
         var _loc10_:EntityView = null;
         var _loc2_:Array = param1.param;
         var _loc4_:Point = new Point();
         if(_loc2_.length < 2)
         {
            logger.info("Usage: <se|ne|nw|sw> [<x> <y>]");
            for each(_loc3_ in BattleFacing.facings)
            {
               _loc6_ = this.library.getOffsetByFacing(_loc3_,_loc4_);
               logger.info("   " + _loc3_ + " " + StringUtil.formatPoint(_loc6_));
            }
            return;
         }
         var _loc5_:String = _loc2_[1];
         _loc5_ = _loc5_.toUpperCase();
         _loc3_ = Enum.parse(BattleFacing,_loc5_) as BattleFacing;
         if(!_loc3_)
         {
            logger.info("No such facing.  Should be one of " + BattleFacing.facings.join(","));
            return;
         }
         _loc6_ = this.library.getOffsetByFacing(_loc3_,_loc4_);
         if(_loc2_.length > 2)
         {
            if(_loc2_.length < 4)
            {
               logger.info("Provide x and y");
               return;
            }
            _loc7_ = Number(_loc2_[2]);
            _loc8_ = Number(_loc2_[3]);
            _loc6_ = this.library.setOffsetByFacing(_loc3_,_loc7_,_loc8_);
            _loc9_ = BattleBoardView.instance;
            for each(_loc10_ in _loc9_.entityViews)
            {
               if(_loc10_.animSprite.library == this.library)
               {
                  _loc10_.animSprite._offsetsByFacing = this.library.offsetsByFacing;
               }
            }
         }
         logger.info("   " + _loc3_ + " " + StringUtil.formatPoint(_loc6_));
         this.handleLibraryChanged();
      }
      
      private function handleLibraryChanged() : void
      {
         var _loc2_:EntityView = null;
         var _loc1_:BattleBoardView = BattleBoardView.instance;
         if(!_loc1_)
         {
            return;
         }
         for each(_loc2_ in _loc1_.entityViews)
         {
            if(Boolean(_loc2_.animSprite) && _loc2_.animSprite.library == this.library)
            {
               _loc2_.animSprite.handleOffsetsChanged();
            }
         }
      }
   }
}
