package game.gui.battle
{
   import com.greensock.TweenMax;
   import engine.battle.fsm.BattleRewardData;
   import engine.entity.def.Item;
   import flash.display.MovieClip;
   import flash.errors.IllegalOperationError;
   import flash.geom.Point;
   import flash.text.TextField;
   import game.gui.GuiItemSlot;
   import game.gui.GuiTextCentered;
   import game.gui.IGuiContext;
   
   public class GuiMatchResolution_Items implements IGuiMatchResolution_Panel
   {
       
      
      public var _panel:MovieClip;
      
      public var _spear:MovieClip;
      
      public var _context:IGuiContext;
      
      private var itemsStartingY:Number;
      
      private var panHeight:int;
      
      private var awardSubCategory:TextField;
      
      private var awardTitle_gtc:GuiTextCentered;
      
      private var awardBody:TextField;
      
      private var awardIcon:GuiItemSlot;
      
      private const awardIconCount:int = 6;
      
      private var currentAwardIndex:int = 0;
      
      private var awardCount:int;
      
      private var awardIds:Vector.<String>;
      
      private var callbackFinished:Function;
      
      private var brd:BattleRewardData;
      
      public var container:IGuiMatchResolution_PanelContainer;
      
      public var iconPt:Point;
      
      public var spearPt:Point;
      
      public var bodyPt:Point;
      
      public var awardTitleWidth:int;
      
      private var _finished:Boolean;
      
      public function GuiMatchResolution_Items(param1:IGuiMatchResolution_PanelContainer, param2:MovieClip, param3:Function)
      {
         this.awardIds = new Vector.<String>();
         this.iconPt = new Point();
         this.spearPt = new Point();
         this.bodyPt = new Point();
         super();
         this.container = param1;
         this._panel = param2;
         this._panel.visible = false;
         this.itemsStartingY = this._panel.y;
         this.callbackFinished = param3;
         this.panHeight = this._panel.height;
         this.awardSubCategory = this._panel.getChildByName("subcategory") as TextField;
         this.awardSubCategory.mouseEnabled = false;
         this.awardTitle_gtc = this._panel.getChildByName("title") as GuiTextCentered;
         this._spear = this._panel.getChildByName("spear") as MovieClip;
         this._spear.mouseEnabled = false;
         this.awardBody = this._panel.getChildByName("body") as TextField;
         this.awardBody.mouseEnabled = false;
         this.awardIcon = this._panel.getChildByName("icon") as GuiItemSlot;
         this.awardIcon.mouseEnabled = this.awardIcon.mouseChildren = false;
         this.iconPt.setTo(this.awardIcon.x,this.awardIcon.y);
         this.spearPt.setTo(this._spear.x,this._spear.y);
         this.bodyPt.setTo(this.awardBody.x,this.awardBody.y);
         this._panel.mouseEnabled = this._panel.mouseChildren = false;
      }
      
      public function init(param1:IGuiContext) : void
      {
         this._context = param1;
         this.awardTitle_gtc.init(param1);
         this.awardIcon.init(param1);
      }
      
      public function setupAwards(param1:BattleRewardData) : void
      {
         var _loc2_:String = null;
         this.brd = param1;
         this.awardCount = 0;
         if(!param1)
         {
            return;
         }
         for each(_loc2_ in param1.items)
         {
            this.awardIds.push(_loc2_);
         }
         this.awardCount = this.awardIds.length;
      }
      
      public function cleanup() : void
      {
         TweenMax.killTweensOf(this._panel);
         TweenMax.killTweensOf(this._spear);
         TweenMax.killTweensOf(this.awardBody);
         TweenMax.killTweensOf(this.awardTitle_gtc);
         TweenMax.killTweensOf(this.awardIcon);
         TweenMax.killDelayedCallsTo(this._shrinkIcon);
         TweenMax.killDelayedCallsTo(this._next);
         this.awardIds = null;
      }
      
      public function fillAndDisplayAward(param1:Item) : void
      {
         this._panel.y = this.itemsStartingY - this.panHeight;
         this.awardSubCategory.text = this._context.translate("items");
         this.awardTitle_gtc.scale = 1;
         this.awardTitle_gtc.resetPosition();
         this.awardTitle_gtc.setHtmlText(param1.def.name);
         this._spear.x = this.spearPt.x;
         this._spear.y = this.spearPt.y;
         this.awardIcon.scaleX = this.awardIcon.scaleY = 1;
         this.awardIcon.x = this.iconPt.x;
         this.awardIcon.y = this.iconPt.y;
         this.awardIcon.item = param1;
         this.awardBody.htmlText = param1.def.description;
         this.awardBody.visible = false;
         this.awardBody.x = this.bodyPt.x;
         this.awardBody.y = this.bodyPt.y;
         this._panel.visible = true;
         this._context.locale.fixTextFieldFormat(this.awardBody);
         this._context.locale.fixTextFieldFormat(this.awardSubCategory);
         TweenMax.to(this._panel,0.4,{
            "y":this.itemsStartingY,
            "onComplete":this._onPannedIn
         });
      }
      
      private function _onPannedIn() : void
      {
         TweenMax.delayedCall(1,this._shrinkIcon);
      }
      
      private function _shrinkIcon() : void
      {
         var _loc1_:Number = 0.5;
         var _loc2_:Number = 0.75;
         this.awardBody.alpha = 0;
         this.awardBody.visible = true;
         TweenMax.to(this._spear,0.4,{"y":-21});
         TweenMax.to(this.awardBody,0.4,{
            "y":-1,
            "alpha":1
         });
         TweenMax.to(this.awardTitle_gtc,0.4,{
            "scaleX":_loc2_,
            "scaleY":_loc2_,
            "y":-127
         });
         TweenMax.to(this.awardIcon,0.4,{
            "scaleX":_loc1_,
            "scaleY":_loc1_,
            "x":172,
            "y":-164,
            "onComplete":this._onBodyShown
         });
      }
      
      private function _onBodyShown() : void
      {
         TweenMax.delayedCall(4,this._next);
      }
      
      private function _next() : void
      {
         if(!this._context)
         {
            return;
         }
         if(this._finished)
         {
            throw new IllegalOperationError("already finished");
         }
         ++this.currentAwardIndex;
         this._context.logger.info("awardIndex: " + this.currentAwardIndex + " awardCount: " + this.awardCount);
         if(this.currentAwardIndex < this.awardCount)
         {
            TweenMax.to(this._panel,0.4,{
               "y":this.itemsStartingY + this.panHeight,
               "onComplete":this.displayItems
            });
         }
         else
         {
            this._finished = true;
            this.callbackFinished();
         }
      }
      
      public function hideItems() : void
      {
         this._panel.visible = false;
      }
      
      public function get empty() : Boolean
      {
         return this.awardCount <= 0;
      }
      
      public function displayItems() : void
      {
         this.container.setPanel(this,true);
         var _loc1_:String = this.awardIds[this.currentAwardIndex];
         var _loc2_:Item = this._context.saga.caravan.legend.items.getItem(_loc1_);
         if(!_loc2_)
         {
            throw new IllegalOperationError("fail item " + _loc1_);
         }
         this.fillAndDisplayAward(_loc2_);
      }
      
      public function slideOut(param1:Function) : void
      {
         this.container.setPanel(this,false);
         TweenMax.to(this._panel,0.4,{
            "delay":2,
            "y":this.itemsStartingY + this.panHeight,
            "onComplete":param1
         });
      }
   }
}
