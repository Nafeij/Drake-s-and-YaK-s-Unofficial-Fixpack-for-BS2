package game.gui.page
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityAppearanceDef;
   import engine.entity.def.IEntityAssetBundle;
   import engine.entity.def.IEntityAssetBundleManager;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IPartyDef;
   import engine.entity.def.Item;
   import engine.entity.def.Legend;
   import engine.resource.AnimClipResource;
   import engine.resource.BitmapResource;
   import engine.resource.Resource;
   import engine.resource.ResourceCollector;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   
   public class HeroesPageCache
   {
       
      
      private var gp:GamePage;
      
      private var config:GameConfig;
      
      private var party:IPartyDef;
      
      private var cachedPortraits:Dictionary;
      
      public function HeroesPageCache(param1:GamePage)
      {
         this.cachedPortraits = new Dictionary();
         super();
         this.gp = param1;
         this.config = param1.config;
      }
      
      public function cleanup() : void
      {
         if(this.party)
         {
            this.party.removeEventListener(Event.CHANGE,this.handlePartyChange);
            this.party = null;
         }
      }
      
      private function handlePartyChange(param1:Event) : void
      {
         this.cachePartyPortraits();
      }
      
      public function getPageResource(param1:String, param2:Class) : Resource
      {
         if(param1)
         {
            return this.gp.getPageResource(param1,param2);
         }
         return null;
      }
      
      protected function releasePageResource(param1:String) : void
      {
         return this.gp.releasePageResource(param1);
      }
      
      public function handleLoaded() : void
      {
      }
      
      public function init() : void
      {
         var _loc3_:Item = null;
         var _loc4_:IEntityDef = null;
         var _loc5_:IEntityAppearanceDef = null;
         var _loc6_:int = 0;
         var _loc7_:BattleAbilityDef = null;
         var _loc1_:Legend = this.config.legend;
         this.party = _loc1_.party;
         this.party.addEventListener(Event.CHANGE,this.handlePartyChange);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.roster.numCombatants)
         {
            _loc4_ = _loc1_.roster.getEntityDef(_loc2_);
            if(_loc4_.defItem)
            {
               this.getPageResource(_loc4_.defItem.def.icon,BitmapResource);
            }
            _loc5_ = _loc4_.appearance;
            this.getPageResource(_loc5_.getIconUrl(EntityIconType.PARTY),BitmapResource);
            this.getPageResource(_loc5_.getIconUrl(EntityIconType.ROSTER),BitmapResource);
            this.getPageResource(_loc5_.getIconUrl(EntityIconType.INIT_ORDER),BitmapResource);
            if(_loc4_.actives)
            {
               _loc6_ = 0;
               while(_loc6_ < _loc4_.actives.numAbilities)
               {
                  _loc7_ = _loc4_.actives.getAbilityDef(_loc6_) as BattleAbilityDef;
                  if(!(_loc7_.tag != BattleAbilityTag.SPECIAL && _loc7_.tag != BattleAbilityTag.PASSIVE))
                  {
                     if(!_loc7_.pgHide)
                     {
                        if(_loc7_.iconLargeUrl)
                        {
                           this.getPageResource(_loc7_.iconLargeUrl,BitmapResource);
                        }
                     }
                  }
                  _loc6_++;
               }
            }
            if(_loc4_.passives)
            {
               _loc6_ = 0;
               while(_loc6_ < _loc4_.passives.numAbilities)
               {
                  _loc7_ = _loc4_.passives.getAbilityDef(_loc6_) as BattleAbilityDef;
                  if(!(_loc7_.tag != BattleAbilityTag.SPECIAL && _loc7_.tag != BattleAbilityTag.PASSIVE))
                  {
                     if(_loc7_.iconLargeUrl)
                     {
                        this.getPageResource(_loc7_.iconLargeUrl,BitmapResource);
                     }
                  }
                  _loc6_++;
               }
            }
            _loc2_++;
         }
         this.cachePartyPortraits();
         for each(_loc3_ in _loc1_.items.items)
         {
            this.getPageResource(_loc3_.def.icon,BitmapResource);
         }
         this.performResourceCollection();
      }
      
      private function performResourceCollection() : void
      {
         var _loc4_:IEntityDef = null;
         var _loc5_:IEntityAssetBundle = null;
         if(!ResourceCollector.ENABLED)
         {
            return;
         }
         var _loc1_:Legend = this.config.legend;
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:IEntityAssetBundleManager = this.config._eabm;
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_.roster.numCombatants)
         {
            _loc4_ = _loc1_.roster.getEntityDef(_loc3_);
            _loc5_ = _loc2_.getEntityPreload(_loc4_,null,true,true,true);
            _loc5_.loadVersus();
            _loc3_++;
         }
      }
      
      private function cachePartyPortraits() : void
      {
         var _loc1_:* = null;
         var _loc2_:int = 0;
         var _loc3_:IEntityDef = null;
         var _loc4_:IEntityAppearanceDef = null;
         var _loc5_:int = 0;
         if(!this.party)
         {
            return;
         }
         for(_loc1_ in this.cachedPortraits)
         {
            this.cachedPortraits[_loc1_] = 0;
         }
         _loc2_ = 0;
         while(_loc2_ < this.party.numMembers)
         {
            _loc3_ = this.party.getMember(_loc2_);
            _loc4_ = _loc3_.appearance;
            this.cachePortraitUrl(_loc4_.portraitUrl);
            _loc2_++;
         }
         for(_loc1_ in this.cachedPortraits)
         {
            _loc5_ = int(this.cachedPortraits[_loc1_]);
            if(!_loc5_)
            {
               this.releasePageResource(_loc1_);
            }
         }
      }
      
      private function cachePortraitUrl(param1:String) : void
      {
         this.getPageResource(param1,AnimClipResource);
         var _loc2_:int = int(this.cachedPortraits[param1]);
         _loc2_++;
         this.cachedPortraits[param1] = _loc2_;
      }
   }
}
