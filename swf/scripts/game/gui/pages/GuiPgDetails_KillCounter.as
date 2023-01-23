package game.gui.pages
{
   import com.stoicstudio.platform.Platform;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityDef;
   import engine.gui.GuiUtil;
   import engine.stat.def.StatType;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.IGuiContext;
   
   public class GuiPgDetails_KillCounter
   {
       
      
      public var killCounterText:TextField;
      
      public var skulls:MovieClip;
      
      public var skulls_gold:MovieClip;
      
      public const killGoldTextColor:String = "#e7bc43";
      
      public const currentKillTextColor:String = "#e63526";
      
      public const killsToPromoteTextColor:String = "#b1615a";
      
      public var _killCounter:MovieClip;
      
      public var context:IGuiContext;
      
      public var logger:ILogger;
      
      public function GuiPgDetails_KillCounter(param1:DisplayObjectContainer)
      {
         super();
         this._killCounter = param1.getChildByName("killCounter") as MovieClip;
         this.killCounterText = this._killCounter.getChildByName("killText") as TextField;
         this.skulls = this._killCounter.getChildByName("skulls") as MovieClip;
         this.skulls_gold = this._killCounter.getChildByName("skulls_gold") as MovieClip;
         if(Platform.requiresUiSafeZoneBuffer)
         {
            this._killCounter.y -= 50;
         }
      }
      
      public function init(param1:IGuiContext) : void
      {
         this.context = param1;
         this.logger = param1.logger;
         var _loc2_:String = param1.censorId;
         GuiUtil.performCensor(this.skulls,_loc2_,this.logger);
         GuiUtil.performCensor(this.skulls_gold,_loc2_,this.logger);
      }
      
      public function set visible(param1:Boolean) : void
      {
         this._killCounter.visible = param1;
         this.killCounterText.visible = param1;
         this.skulls.visible = param1;
         this.skulls_gold.visible = param1;
      }
      
      public function updateKillCounter(param1:IEntityDef, param2:IGuiContext) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         _loc3_ = int(param1.stats.getValue(StatType.RANK));
         _loc4_ = int(param1.stats.getValue(StatType.KILLS));
         var _loc5_:int = param1.statRanges.getStatRange(StatType.RANK).max;
         if(_loc3_ >= _loc5_ && _loc3_ > 1)
         {
            this.skulls_gold.visible = true;
            this.skulls.visible = false;
            this.killCounterText.htmlText = "<font color=\"" + this.killGoldTextColor + "\">" + _loc4_ + "</font>";
         }
         else
         {
            this.skulls_gold.visible = false;
            this.skulls.visible = true;
            _loc6_ = param2.statCosts.getKillsRequiredToPromote(_loc3_);
            this.killCounterText.htmlText = "<font color=\"" + this.currentKillTextColor + "\">" + _loc4_ + "</font>" + "<font color=\"" + this.killsToPromoteTextColor + "\">/" + _loc6_ + "</font>";
         }
      }
   }
}
