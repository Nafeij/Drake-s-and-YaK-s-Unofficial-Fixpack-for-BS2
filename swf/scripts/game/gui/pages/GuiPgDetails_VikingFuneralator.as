package game.gui.pages
{
   import com.greensock.TweenMax;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.ILegend;
   import engine.gui.GuiButtonState;
   import engine.math.MathUtil;
   import engine.saga.Saga;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   
   public class GuiPgDetails_VikingFuneralator
   {
       
      
      public var details:GuiPgDetails;
      
      public var legend:ILegend;
      
      public var roster:IEntityListDef;
      
      public var reward:int;
      
      public var entity:IEntityDef;
      
      public var saga:Saga;
      
      public var musics:Array;
      
      private var _callback:Function;
      
      private var _orig_x_stats:int;
      
      private var _orig_mouse_enabled:Boolean;
      
      private var _orig_mouse_children:Boolean;
      
      public function GuiPgDetails_VikingFuneralator(param1:GuiPgDetails)
      {
         this.musics = ["saga2/music/ch9/9mC-V","saga2/music/ch11/11mC3-V","saga2/music/ch13/13mC-V"];
         super();
         this.details = param1;
         this.saga = param1.context.saga;
         this.legend = this.saga.caravan.legend;
         this.roster = this.legend.roster;
      }
      
      public function startFuneral(param1:IEntityDef, param2:int, param3:Function) : void
      {
         this.reward = param2;
         this.entity = param1;
         this._callback = param3;
         this._orig_mouse_enabled = this.details.pg.mouseEnabled;
         this._orig_mouse_children = this.details.pg.mouseChildren;
         this.details._button$survival_funeral_hero.visible = false;
         this.details.pg.mouseEnabled = false;
         this.details.pg.mouseChildren = false;
         this.startMusic();
         this.startAnimatingStats();
      }
      
      private function startMusic() : void
      {
         var _loc1_:int = MathUtil.randomInt(0,this.musics.length - 1);
         var _loc2_:String = this.musics[_loc1_];
         var _loc3_:ActionDef = new ActionDef(null);
         _loc3_.type = ActionType.MUSIC_ONESHOT;
         _loc3_.id = _loc2_;
         this.saga.executeActionDef(_loc3_,null,null);
      }
      
      private function startAnimatingStats() : void
      {
         this._orig_x_stats = this.details._characterStats.x;
         TweenMax.to(this.details._characterStats,1,{
            "x":2731,
            "onComplete":this.tweenAnimatingStatsHandler
         });
         TweenMax.to(this.details._button$bio,1,{"alpha":0});
         TweenMax.to(this.details.buttonLeft,1,{"alpha":0});
         TweenMax.to(this.details.buttonRight,1,{"alpha":0});
         TweenMax.to(this.details._arrow_bg,1,{"alpha":0});
      }
      
      private function tweenAnimatingStatsHandler() : void
      {
         this.startAnimatingPortrait();
      }
      
      private function startAnimatingPortrait() : void
      {
         TweenMax.to(this.details.portrait,3,{
            "alpha":0,
            "onComplete":this.tweenAnimatingPortraitHandler
         });
      }
      
      private function tweenAnimatingPortraitHandler() : void
      {
         this.legend.renown += this.reward;
         this.details.pg.renown.setStateForCertainTimeframe(GuiButtonState.HOVER,250);
         TweenMax.delayedCall(1,this.preFinished);
      }
      
      private function preFinished() : void
      {
         this.applyFinish(true);
      }
      
      public function restoreVisualStates() : void
      {
         this.details._characterStats.x = this._orig_x_stats;
         this.details.pg.mouseEnabled = this._orig_mouse_enabled;
         this.details.pg.mouseChildren = this._orig_mouse_children;
         this.details._button$bio.alpha = 1;
         this.details.portrait.alpha = 1;
         this.details.buttonLeft.alpha = 1;
         this.details.buttonRight.alpha = 1;
         this.details._arrow_bg.alpha = 1;
      }
      
      private function applyFinish(param1:Boolean) : void
      {
         var _loc2_:Function = null;
         this.roster.removeEntityDef(this.entity);
         this.legend.party.removeMember(this.entity.id);
         if(param1)
         {
            _loc2_ = this._callback;
            this._callback = null;
            if(_loc2_ != null)
            {
               _loc2_();
            }
         }
      }
      
      public function forceFinish() : void
      {
         this.applyFinish(false);
         this.restoreVisualStates();
      }
   }
}
