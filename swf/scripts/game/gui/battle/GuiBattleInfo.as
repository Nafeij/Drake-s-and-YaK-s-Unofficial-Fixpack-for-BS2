package game.gui.battle
{
   import com.greensock.TweenMax;
   import engine.ability.IAbilityDef;
   import engine.ability.IAbilityDefLevel;
   import engine.ability.IAbilityDefLevels;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.model.EffectPhase;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.effect.model.IPersistedEffects;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.locale.LocaleCategory;
   import engine.core.util.ColorUtil;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.Item;
   import engine.gui.GuiUtil;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.text.TextField;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.battle.initiative.GuiInitiativeFrame;
   import game.gui.battle.initiative.GuiInitiativeUnitInfoBanner;
   
   public class GuiBattleInfo extends GuiBase implements IGuiBattleInfo
   {
      
      private static var FONT_HTML_ACTIVE:String = "<font color=\"#c3acfd\">";
      
      private static var FONT_HTML_END:String = "</font>";
       
      
      public var _infoTextField:TextField;
      
      private var mouseDown:Boolean;
      
      private var infoBar:MovieClip;
      
      private var buffs:Vector.<GuiBattleInfo_BuffObject>;
      
      private const maxBuffsToRender:int = 5;
      
      private var activeBuffContainer:MovieClip;
      
      private var setText:Boolean = true;
      
      private var startingParent:Sprite;
      
      private var _entity:IBattleEntity;
      
      private var _infoTextFieldSize:Point;
      
      private var unitInfoBanner:GuiInitiativeUnitInfoBanner;
      
      public var listener:IGuiInitiativeListener;
      
      public var hiding:Boolean;
      
      public function GuiBattleInfo()
      {
         this.buffs = new Vector.<GuiBattleInfo_BuffObject>();
         this._infoTextFieldSize = new Point();
         super();
      }
      
      public function init(param1:IGuiContext, param2:IGuiInitiativeListener) : void
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:MovieClip = null;
         var _loc6_:GuiBattleInfo_BuffObject = null;
         initGuiBase(param1);
         this.listener = param2;
         this._infoTextField = requireGuiChild("infoTextField") as TextField;
         this.startingParent = parent as Sprite;
         this._infoTextField.htmlText = "";
         this._infoTextFieldSize.x = this._infoTextField.width;
         this._infoTextFieldSize.y = this._infoTextField.height;
         this._infoTextField.mouseEnabled = false;
         this.activeBuffContainer = new MovieClip();
         this.activeBuffContainer.name = "buff_container";
         this.activeBuffContainer.mouseEnabled = false;
         this.activeBuffContainer.mouseChildren = true;
         this.addChild(this.activeBuffContainer);
         while(_loc3_ < this.maxBuffsToRender)
         {
            _loc4_ = "buff" + (_loc3_ + 1).toString();
            _loc5_ = getChildByName(_loc4_) as MovieClip;
            _loc6_ = new GuiBattleInfo_BuffObject(this,_loc5_);
            this.activeBuffContainer.addChild(_loc6_.buffMovieClip);
            this.buffs.push(_loc6_);
            _loc3_++;
         }
         this.unitInfoBanner = getChildByName("unitInfoBanner") as GuiInitiativeUnitInfoBanner;
         this.unitInfoBanner.init(param1);
         this.unitInfoBanner.entity = null;
         this.unitInfoBanner.mouseChildren = this.unitInfoBanner.mouseEnabled = false;
         mouseEnabled = false;
         mouseChildren = true;
         this.setVisible(false);
      }
      
      public function cleanup() : void
      {
         var _loc1_:GuiBattleInfo_BuffObject = null;
         this.unitInfoBanner.cleanup();
         for each(_loc1_ in this.buffs)
         {
            _loc1_.cleanup();
         }
         this.buffs = null;
         this.startingParent = null;
         this._entity = null;
         super.cleanupGuiBase();
      }
      
      override public function handleLocaleChange() : void
      {
         super.handleLocaleChange();
         _context.locale.fixTextFieldFormat(this._infoTextField,null,null,true);
         GuiUtil.scaleTextToFit2dWordwrap(this._infoTextField,this._infoTextFieldSize.x,this._infoTextFieldSize.y);
      }
      
      public function setEntityName(param1:String, param2:uint) : void
      {
         var _loc3_:String = ColorUtil.colorStr(param2);
         var _loc4_:* = "<font color=\'" + _loc3_ + "\'>" + param1 + "</font>";
         this.unitInfoBanner.setEntityName(param1,param2);
      }
      
      public function set text(param1:String) : void
      {
         if(this._infoTextField)
         {
            this._infoTextField.htmlText = !!param1 ? param1 : "";
            this.handleLocaleChange();
         }
      }
      
      private function onDoneHiding() : void
      {
         visible = false;
         GuiUtil.updateDisplayList(this,this.startingParent);
         this.setText = true;
      }
      
      public function set entity(param1:IBattleEntity) : void
      {
         this._entity = param1;
         this.unitInfoBanner.entity = param1;
      }
      
      public function set entityDef(param1:IEntityDef) : void
      {
         this.unitInfoBanner.setEntityByDef(param1,true);
      }
      
      public function get isVisible() : Boolean
      {
         return visible && !this.hiding;
      }
      
      public function setVisible(param1:Boolean) : void
      {
         if(param1)
         {
            this.hiding = false;
            this.setText = true;
            visible = true;
            TweenMax.killTweensOf(this);
            GuiUtil.updateDisplayListAtIndex(this,this.startingParent,1);
            if(alpha != 1)
            {
               TweenMax.to(this,0.2,{"alpha":1});
            }
         }
         else
         {
            TweenMax.killTweensOf(this);
            this.hiding = true;
            this.setText = false;
            if(alpha != 0)
            {
               TweenMax.to(this,0.2,{
                  "alpha":0,
                  "onComplete":this.onDoneHiding
               });
            }
            else
            {
               visible = false;
            }
            this.killAllTooltips();
         }
         this.unitInfoBanner.setVisible(param1);
      }
      
      public function killAllTooltips() : void
      {
         var _loc1_:GuiBattleInfo_BuffObject = null;
         if(this.buffs)
         {
            for each(_loc1_ in this.buffs)
            {
               if(_loc1_)
               {
                  _loc1_.killAllTooltips();
               }
            }
         }
      }
      
      public function displayBuffs(param1:GuiInitiativeFrame) : void
      {
         var _loc6_:IEffect = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:BattleAbility = null;
         var _loc10_:Number = NaN;
         var _loc2_:int = 0;
         var _loc3_:Number = 60;
         var _loc4_:GuiBattleInfo_BuffObject = null;
         var _loc5_:Number = 0;
         if(Boolean(this._entity) && Boolean(this._entity.effects))
         {
            for each(_loc6_ in this._entity.effects.effects)
            {
               _loc7_ = _loc6_.phase.index;
               _loc8_ = EffectPhase.REMOVED.index;
               if(_loc7_ < _loc8_ && Boolean(_loc6_.ability.def.iconBuffUrl))
               {
                  _loc9_ = _loc6_.ability as BattleAbility;
                  _loc4_ = this.buffs[_loc2_];
                  _loc4_.setBuffInfo(param1.entity,_loc9_);
                  _loc4_.buffMovieClip.x = _loc5_;
                  if(_loc5_)
                  {
                     _loc5_ += _loc3_;
                  }
                  _loc10_ = _loc4_.buffMovieClip.width;
                  _loc5_ += _loc10_;
                  _loc2_++;
               }
            }
         }
         this.activeBuffContainer.x = -_loc5_ / 2;
         while(_loc2_ < this.maxBuffsToRender)
         {
            _loc4_ = this.buffs[_loc2_];
            _loc4_.setBuffInfo(null,null);
            _loc2_++;
         }
      }
      
      public function showBattleEntityAbilities(param1:IBattleEntity, param2:Boolean) : void
      {
         if(!param1)
         {
            this.text = null;
            return;
         }
         this.text = this.getEntityAbilityString(param1.def,param2,param1.effects,param1.entityItem,param1.titleItem);
      }
      
      public function showEntityDefAbilities(param1:IEntityDef, param2:Boolean) : void
      {
         this.text = this.getEntityAbilityString(param1,param2,null);
      }
      
      public function showAbilityInfo(param1:BattleAbilityDef, param2:int) : void
      {
         var _loc5_:BattleAbilityDef = null;
         var _loc6_:String = null;
         if(!param1 && param1.tag != BattleAbilityTag.SPECIAL)
         {
            return;
         }
         var _loc3_:String = "";
         _loc3_ += FONT_HTML_ACTIVE + param1.name + ": " + param1.descriptionBrief + FONT_HTML_END + "\n";
         var _loc4_:int = 1;
         while(_loc4_ <= param2)
         {
            if(_loc4_ == param1.level)
            {
            }
            _loc5_ = param1.getAbilityDefForLevel(_loc4_) as BattleAbilityDef;
            if(_loc5_.maxLevel > 1)
            {
               _loc6_ = String(context.locale.translateGui("pg_abl_rank"));
               _loc6_ = _loc6_.replace("$RANK",_loc4_.toString());
               _loc3_ += _loc6_ + ": " + _loc5_.descriptionRank + "\n";
            }
            else
            {
               _loc3_ += _loc5_.descriptionRank + "\n";
            }
            _loc4_++;
         }
         this.text = _loc3_;
         this.setVisible(true);
      }
      
      private function getEntityAbilityString(param1:IEntityDef, param2:Boolean, param3:IPersistedEffects = null, param4:Item = null, param5:Item = null) : String
      {
         var _loc7_:Item = null;
         var _loc8_:String = null;
         var _loc6_:* = "";
         if(param1 != null)
         {
            _loc6_ += this.printPassives(param1,param3);
            _loc6_ += this.printActives(param1);
            _loc7_ = !!param4 ? param4 : param1.defItem;
            if(Boolean(_loc7_) && param2)
            {
               _loc6_ += _loc7_.def.colorizedName + ": " + _loc7_.def.brief;
               if(param5)
               {
                  _loc6_ += "\n";
               }
            }
            if(Boolean(param5) && param2)
            {
               _loc8_ = String(context.locale.translate(LocaleCategory.TITLE,param5.def.id));
               _loc6_ += param1.defTitle.getName(param1.gender) + ": " + _loc8_;
            }
         }
         return _loc6_;
      }
      
      private function printPassives(param1:IEntityDef, param2:IPersistedEffects) : String
      {
         var _loc6_:IAbilityDefLevel = null;
         var _loc7_:IAbilityDef = null;
         var _loc3_:IAbilityDefLevels = param1.passives;
         var _loc4_:* = "";
         if(!_loc3_)
         {
            return _loc4_;
         }
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_.numAbilities)
         {
            _loc6_ = _loc3_.getAbilityDefLevel(_loc5_);
            if(_loc6_.level > 0)
            {
               if(!(Boolean(param2) && !param2.hasBattleAbilitiesByDef(_loc6_.def as IBattleAbilityDef)))
               {
                  _loc7_ = _loc6_.def;
                  _loc4_ += "<font color=\"#f5d3ac\">";
                  _loc4_ += _loc7_.name + " - " + _loc7_.descriptionBrief;
                  _loc4_ += "</font>\n";
               }
            }
            _loc5_++;
         }
         return _loc4_;
      }
      
      private function printActives(param1:IEntityDef) : String
      {
         var _loc4_:Boolean = false;
         var _loc6_:IAbilityDefLevel = null;
         var _loc7_:BattleAbilityDef = null;
         var _loc8_:int = 0;
         var _loc2_:IAbilityDefLevels = param1.actives;
         var _loc3_:String = "";
         if(!_loc2_)
         {
            return _loc3_;
         }
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_.numAbilities)
         {
            _loc6_ = _loc2_.getAbilityDefLevel(_loc5_);
            if(_loc6_.level > 0)
            {
               _loc7_ = _loc6_.def as BattleAbilityDef;
               if(_loc7_.tag == BattleAbilityTag.SPECIAL)
               {
                  _loc8_ = Math.min(_loc6_.level,_loc6_.def.maxLevel);
                  _loc7_ = _loc7_.getAbilityDefForLevel(_loc8_) as BattleAbilityDef;
                  if(_loc7_)
                  {
                     if(!_loc4_)
                     {
                        _loc3_ += FONT_HTML_ACTIVE;
                        _loc4_ = true;
                     }
                     _loc3_ += _loc7_.name + ": " + _loc7_.descriptionBrief + "\n";
                  }
               }
            }
            _loc5_++;
         }
         if(_loc4_)
         {
            _loc3_ += FONT_HTML_END;
         }
         return _loc3_;
      }
   }
}
