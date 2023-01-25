package game.gui
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.util.StringUtil;
   import engine.entity.def.Item;
   import engine.entity.def.ItemDef;
   import engine.saga.SagaVar;
   import engine.saga.vars.VariableType;
   import engine.stat.def.StatModDef;
   import engine.stat.def.StatType;
   import engine.talent.Talent;
   import flash.utils.Dictionary;
   
   public class GuiBattleStatFlagTooltip extends GuiBase implements IGuiBattleStatFlagTooltip
   {
      
      private static var stat_tokens:Dictionary;
      
      private static const ABL_ICON_SCALE:Number = 1.5;
       
      
      private var _tooltips:Vector.<GuiToolTip>;
      
      private var _contentIndex:int = 0;
      
      private var _entity:IBattleEntity;
      
      private var _statType:StatType;
      
      public function GuiBattleStatFlagTooltip()
      {
         var _loc2_:String = null;
         var _loc3_:GuiToolTip = null;
         this._tooltips = new Vector.<GuiToolTip>();
         super();
         this.mouseEnabled = this.mouseChildren = false;
         var _loc1_:int = 0;
         while(_loc1_ < 10)
         {
            _loc2_ = "tip_" + _loc1_.toString();
            _loc3_ = getChildByName(_loc2_) as GuiToolTip;
            if(!_loc3_)
            {
               break;
            }
            this._tooltips.push(_loc3_);
            _loc3_.visible = false;
            _loc1_++;
         }
         if(!stat_tokens)
         {
            stat_tokens = new Dictionary();
            stat_tokens[StatType.STRENGTH] = "pg_q_stat_strength";
            stat_tokens[StatType.ARMOR] = "pg_q_stat_armor";
            stat_tokens[StatType.WILLPOWER] = "pg_q_stat_willpower";
            stat_tokens[StatType.EXERTION] = "pg_q_stat_exertion";
            stat_tokens[StatType.ARMOR_BREAK] = "pg_q_stat_break";
         }
         visible = false;
      }
      
      public static function prepareContent(param1:IGuiContext, param2:IBattleEntity, param3:StatType, param4:Vector.<GuiIcon>, param5:Vector.<String>) : void
      {
         var _loc6_:String = null;
         var _loc7_:GuiIcon = null;
      }
      
      private static function _getContentWillpower(param1:IGuiContext, param2:IBattleEntity, param3:Boolean = true) : Object
      {
         var _loc4_:String = null;
         var _loc5_:GuiIcon = null;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         if(param2.isPlayer)
         {
            _loc6_ = param1.saga.getVar(SagaVar.VAR_MORALE_BONUS_WILLPOWER,VariableType.INTEGER).asInteger;
            if(_loc6_)
            {
               if(param3)
               {
                  _loc4_ = String(param1.translateRaw("tt_battle_morale"));
                  if(!_loc4_)
                  {
                     return null;
                  }
                  _loc4_ = _loc4_.replace("$AMOUNT",StringUtil.numberWithSign(_loc6_,0));
               }
               _loc7_ = param1.saga.getMoraleIconUrl();
               if(_loc7_)
               {
                  _loc5_ = param1.getIconResourceGroup(_loc7_,param2.resourceGroup);
               }
               return {
                  "s":_loc4_,
                  "icon":_loc5_
               };
            }
         }
         return null;
      }
      
      private static function _getContentStrength(param1:IGuiContext, param2:IBattleEntity, param3:Boolean = true) : Object
      {
         var _loc4_:String = null;
         var _loc5_:GuiIcon = null;
         var _loc6_:BattleAbilityDef = null;
         var _loc7_:int = 0;
         if(param2.stats.getValue(StatType.INJURY))
         {
            _loc6_ = param1.getAbilityDefById("pas_injury") as BattleAbilityDef;
            if(param3)
            {
               _loc4_ = String(param1.translateRaw("tt_battle_injury"));
               if(!_loc4_)
               {
                  return null;
               }
               _loc7_ = -param2.stats.getValue(StatType.INJURY);
               _loc4_ = _loc4_.replace("$AMOUNT",StringUtil.numberWithSign(_loc7_,0));
            }
            _loc5_ = param1.getIconResourceGroup(_loc6_.iconBuffUrl,param2.resourceGroup);
            _loc5_.scaleX = _loc5_.scaleY = ABL_ICON_SCALE;
            return {
               "s":_loc4_,
               "icon":_loc5_
            };
         }
         return null;
      }
      
      private static function _getContentItem(param1:IGuiContext, param2:IBattleEntity, param3:StatType, param4:Boolean = true) : Object
      {
         var _loc5_:* = null;
         var _loc6_:GuiIcon = null;
         var _loc8_:StatModDef = null;
         var _loc9_:int = 0;
         if(Boolean(param1) && Boolean(param1.saga))
         {
            if(param1.saga.battleItemsDisabled)
            {
               return null;
            }
         }
         var _loc7_:Item = param2.item;
         if(_loc7_)
         {
            for each(_loc8_ in _loc7_.def.statmods)
            {
               if(_loc8_.stat == param3)
               {
                  _loc9_ = _loc8_.amount;
                  if(param4)
                  {
                     _loc5_ = _loc7_.def.name + ": ";
                     _loc5_ += ItemDef._printStatModDef(_loc8_,false,param1.locale);
                  }
                  _loc6_ = param1.getIconResourceGroup(_loc7_.def.icon,param2.resourceGroup);
                  return {
                     "s":_loc5_,
                     "icon":_loc6_
                  };
               }
            }
         }
         return null;
      }
      
      private static function _getContentTalent(param1:IGuiContext, param2:IBattleEntity, param3:StatType, param4:Boolean = true) : Object
      {
         var _loc5_:* = null;
         var _loc6_:GuiIcon = null;
         var _loc7_:Talent = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         if(param2.def.talents)
         {
            _loc7_ = param2.def.talents.getTalentByParentStatType(param3);
            if(_loc7_)
            {
               _loc8_ = int(param2.bonusedTalents.talentBonuses[_loc7_]);
               _loc9_ = _loc7_.rank + _loc8_;
               _loc5_ = _loc7_.def.getLocalizedName(param1.locale) + ": ";
               _loc5_ += _loc7_.def.getLocalizedRank(param1.locale,_loc9_);
               _loc6_ = param1.getIconResourceGroup(_loc7_.def.getIconPath(),param2.resourceGroup);
               return {
                  "s":_loc5_,
                  "icon":_loc6_
               };
            }
         }
         return null;
      }
      
      public static function getIconsForStat(param1:IGuiContext, param2:IBattleEntity, param3:StatType) : Vector.<GuiIcon>
      {
         var _loc4_:Vector.<GuiIcon> = null;
         var _loc5_:Object = null;
         if(param3 == StatType.WILLPOWER)
         {
            _loc5_ = _getContentWillpower(param1,param2,false);
            if(_loc5_)
            {
               if(!_loc4_)
               {
                  _loc4_ = new Vector.<GuiIcon>();
               }
               _loc4_.push(_loc5_.icon);
            }
         }
         else if(param3 == StatType.STRENGTH)
         {
            _loc5_ = _getContentStrength(param1,param2,false);
            if(_loc5_)
            {
               if(!_loc4_)
               {
                  _loc4_ = new Vector.<GuiIcon>();
               }
               _loc4_.push(_loc5_.icon);
            }
         }
         _loc5_ = _getContentItem(param1,param2,param3,false);
         if(_loc5_)
         {
            if(!_loc4_)
            {
               _loc4_ = new Vector.<GuiIcon>();
            }
            _loc4_.push(_loc5_.icon);
         }
         _loc5_ = _getContentTalent(param1,param2,param3,false);
         if(_loc5_)
         {
            if(!_loc4_)
            {
               _loc4_ = new Vector.<GuiIcon>();
            }
            _loc4_.push(_loc5_.icon);
         }
         return _loc4_;
      }
      
      public function cleanup() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._tooltips.length)
         {
            this._tooltips[_loc1_].cleanup();
            _loc1_++;
         }
         this._tooltips = null;
         super.cleanupGuiBase();
      }
      
      public function init(param1:IGuiContext) : void
      {
         super.initGuiBase(param1);
         var _loc2_:int = 0;
         while(_loc2_ < this._tooltips.length)
         {
            this._tooltips[_loc2_].init(param1);
            _loc2_++;
         }
      }
      
      public function setContent(param1:IBattleEntity, param2:StatType) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:GuiIcon = null;
         var _loc5_:Object = null;
         if(param1 == this._entity && param2 == this._statType)
         {
            return false;
         }
         this._entity = param1;
         this._statType = param2;
         if(!param1 || !param2)
         {
            return false;
         }
         this.startContent();
         _loc3_ = String(_context.translate(stat_tokens[param2]));
         this.addContent(null,_loc3_);
         if(param2 == StatType.WILLPOWER)
         {
            _loc5_ = _getContentWillpower(_context,this._entity);
            if(_loc5_)
            {
               this.addContent(_loc5_.icon,_loc5_.s);
            }
         }
         else if(param2 == StatType.STRENGTH)
         {
            _loc5_ = _getContentStrength(_context,this._entity);
            if(_loc5_)
            {
               this.addContent(_loc5_.icon,_loc5_.s);
            }
         }
         _loc5_ = _getContentItem(_context,param1,param2);
         if(_loc5_)
         {
            this.addContent(_loc5_.icon,_loc5_.s);
         }
         _loc5_ = _getContentTalent(_context,param1,param2);
         if(_loc5_)
         {
            this.addContent(_loc5_.icon,_loc5_.s);
         }
         this.finishContent();
         return true;
      }
      
      private function startContent() : void
      {
         this._contentIndex = 0;
      }
      
      private function finishContent() : void
      {
         var _loc1_:int = this._contentIndex;
         while(_loc1_ < this._tooltips.length)
         {
            this._tooltips[_loc1_].setContent(null,null);
            this._tooltips[_loc1_].visible = false;
            _loc1_++;
         }
      }
      
      private function addContent(param1:GuiIcon, param2:String) : void
      {
         if(this._contentIndex >= this._tooltips.length)
         {
            _context.logger.error("Unable to add content index " + this._contentIndex + " msg [" + param2 + "]");
            return;
         }
         var _loc3_:GuiToolTip = this._tooltips[this._contentIndex];
         _loc3_.setContent(param1,param2);
         _loc3_.visible = true;
         ++this._contentIndex;
      }
   }
}
