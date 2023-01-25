package game.gui.battle
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.Platform;
   import engine.achievement.AchievementDef;
   import engine.battle.fsm.BattleRenownAwardType;
   import engine.battle.fsm.BattleRewardData;
   import flash.display.MovieClip;
   import flash.errors.IllegalOperationError;
   import flash.text.TextField;
   import game.gui.IGuiContext;
   import game.gui.PopupIconsGroup;
   
   public class GuiMatchResolution_Rewards implements IGuiMatchResolution_Panel
   {
       
      
      public var _rewards:MovieClip;
      
      public var _context:IGuiContext;
      
      public var rewardsStartingY:Number;
      
      public var awardSubCatergory:TextField;
      
      public var awardTitle:TextField;
      
      public var awardRenownIcons:PopupIconsGroup;
      
      public var awardBody:TextField;
      
      public var awardIcon:MovieClip;
      
      public const awardIconCount:int = 6;
      
      public var currentAwardIndex:int = 0;
      
      public var awardCount:int;
      
      public var awardIds:Vector.<String>;
      
      public var callbackFinished:Function;
      
      public var brd:BattleRewardData;
      
      public var container:IGuiMatchResolution_PanelContainer;
      
      private var _finished:Boolean;
      
      public function GuiMatchResolution_Rewards(param1:IGuiMatchResolution_PanelContainer, param2:MovieClip, param3:Function)
      {
         this.awardIds = new Vector.<String>();
         super();
         this.container = param1;
         this._rewards = param2;
         this._rewards.visible = false;
         this.rewardsStartingY = this._rewards.y;
         this.callbackFinished = param3;
      }
      
      public function init(param1:IGuiContext) : void
      {
         this._context = param1;
         this.awardSubCatergory = this._rewards.getChildByName("subcategory") as TextField;
         this.awardSubCatergory.mouseEnabled = false;
         this.awardTitle = this._rewards.getChildByName("title") as TextField;
         this.awardTitle.mouseEnabled = false;
         this.awardBody = this._rewards.getChildByName("body") as TextField;
         this.awardBody.mouseEnabled = false;
         this.awardIcon = this._rewards.getChildByName("awardIcon") as MovieClip;
         this.awardIcon.mouseEnabled = this.awardIcon.mouseChildren = false;
         this.awardRenownIcons = this._rewards.getChildByName("geneicIcons") as PopupIconsGroup;
         this.awardRenownIcons.init(param1,this.awardIconCount);
         this._rewards.mouseEnabled = this._rewards.mouseChildren = false;
      }
      
      public function setupAwards(param1:BattleRewardData) : void
      {
         var _loc2_:Object = null;
         this.brd = param1;
         this.awardCount = 0;
         if(!param1)
         {
            return;
         }
         if(!Platform.suppressUIAchievementNotifications)
         {
            for(_loc2_ in param1.achievements)
            {
               this.awardIds.push(_loc2_);
            }
         }
         if(param1.getAward(BattleRenownAwardType.BOOST) > 0)
         {
            this.awardIds.push("bst_rally");
         }
         if(param1.getAward(BattleRenownAwardType.FRIEND) > 0)
         {
            this.awardIds.push("ref_friend");
         }
         this.awardCount = this.awardIds.length;
      }
      
      public function cleanup() : void
      {
         if(this.awardRenownIcons)
         {
            this.awardRenownIcons.cleanup();
            this.awardRenownIcons = null;
         }
         this.awardIds = null;
      }
      
      public function fillAndDisplayAward(param1:String, param2:String, param3:String, param4:String, param5:int) : void
      {
         this._rewards.y = this.rewardsStartingY - this._rewards.height;
         this.awardRenownIcons.reset();
         this.awardBody.text = param3;
         this.awardSubCatergory.text = param1;
         this.awardTitle.text = param2;
         this.awardIcon.removeChildAt(0);
         this.awardIcon.addChild(this._context.getAwardIcon(param4));
         this._rewards.visible = true;
         this.awardRenownIcons.setup(param5,5,6);
         this._context.locale.fixTextFieldFormat(this.awardBody);
         this._context.locale.fixTextFieldFormat(this.awardTitle);
         this._context.locale.fixTextFieldFormat(this.awardSubCatergory);
         TweenMax.to(this._rewards,0.4,{
            "y":this.rewardsStartingY,
            "onComplete":this.playAwardIcons
         });
      }
      
      private function playAwardIcons() : void
      {
         this.awardRenownIcons.playAndResetPopups(this.awardIconsDoneAnimating);
      }
      
      private function awardIconsDoneAnimating() : void
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
            TweenMax.to(this._rewards,0.4,{
               "delay":2,
               "y":this.rewardsStartingY + this._rewards.height,
               "onComplete":this.displayAwards
            });
         }
         else
         {
            this._finished = true;
            this.callbackFinished();
         }
      }
      
      public function hideRewards() : void
      {
         this._rewards.visible = false;
      }
      
      public function get empty() : Boolean
      {
         return this.awardCount <= 0;
      }
      
      public function displayAwards() : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc7_:AchievementDef = null;
         this.container.setPanel(this,true);
         var _loc1_:String = "";
         var _loc6_:String = this.awardIds[this.currentAwardIndex];
         if(_loc6_ == "bst_rally")
         {
            _loc1_ = String(this._context.translate("boost_subcat"));
            _loc2_ = String(this._context.translate("bst_rally"));
            _loc3_ = String(this._context.translate("bst_rally_description"));
            _loc4_ = "common/achievement/icons/renownboost_achievement_icon.png";
            _loc5_ = this.brd.getAward(BattleRenownAwardType.BOOST);
         }
         else if(_loc6_ == "ref_friend")
         {
            _loc1_ = String(this._context.translate("referral_subcat"));
            _loc2_ = String(this._context.translate("ref_friend"));
            _loc3_ = String(this._context.translate("ref_friend_description"));
            _loc4_ = "common/achievement/icons/friendmatch_achievement_icon.png";
            _loc5_ = this.brd.getAward(BattleRenownAwardType.FRIEND);
         }
         else
         {
            _loc7_ = this._context.getAchievementDef(_loc6_);
            _loc2_ = _loc7_.name;
            _loc3_ = _loc7_.description;
            _loc4_ = _loc7_.iconUrl;
            _loc5_ = _loc7_.renownAwardAmount;
            _loc1_ = String(this._context.translate("achievement_subcat"));
         }
         if(!_loc4_)
         {
            this._context.logger.error("GuiMatchResolution missing icon url for [" + _loc6_ + "]");
         }
         this.fillAndDisplayAward(_loc1_,_loc2_,_loc3_,_loc4_,_loc5_);
      }
      
      public function slideOut(param1:Function) : void
      {
         this.container.setPanel(this,false);
         TweenMax.to(this._rewards,0.4,{
            "delay":2,
            "y":this.rewardsStartingY + this._rewards.height,
            "onComplete":param1
         });
      }
   }
}
