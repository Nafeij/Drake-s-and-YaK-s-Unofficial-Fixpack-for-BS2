package engine.landscape.travel.view
{
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.IPartyDef;
   import engine.landscape.ILandscapeContext;
   import engine.landscape.travel.def.CartDef;
   import engine.landscape.travel.def.TravelDef;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.saga.CaravanViewDef;
   import engine.saga.CaravanViewSpriteDef;
   import engine.saga.Saga;
   import flash.utils.Dictionary;
   
   public class CaravanViewClose extends CaravanView
   {
       
      
      private var T_HERO_PREFIX:String = "hero_";
      
      private var ID_NARRATOR:String = "narrator";
      
      private var ID_EXTRA:String = "bolverk";
      
      private var poleUrl:String = "poleUrlUnset";
      
      private const CLOSE_CARAVAN_LEN:Number = 1200;
      
      private const CLOSE_BANNER_HEIGHT:Number = 156;
      
      private var pole:DisplayObjectWrapper;
      
      private var num_narrator:int = 0;
      
      private var num_extra:int = 0;
      
      private var headsize:int = 0;
      
      private var _heroesDict:Dictionary;
      
      private var _heroes:Vector.<IEntityDef>;
      
      private var poleFailed:Boolean;
      
      private var MAX_GROUPS_PEASANTS:int = 40;
      
      private var MAX_GROUPS_VARL:int = 20;
      
      private var MAX_GROUPS_FIGHTERS:int = 20;
      
      public function CaravanViewClose(param1:TravelView)
      {
         var _loc6_:IEntityListDef = null;
         var _loc7_:int = 0;
         var _loc8_:IEntityDef = null;
         var _loc9_:* = false;
         var _loc10_:* = false;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:String = null;
         this._heroesDict = new Dictionary();
         this._heroes = new Vector.<IEntityDef>();
         super(param1);
         if(saga.caravan)
         {
            this.poleUrl = saga.caravan.closePoleUrl;
         }
         var _loc2_:TravelDef = param1.travel.def;
         var _loc3_:CartDef = saga.getCartDef();
         def = CaravanViewDef.ctorClose(_loc2_.showYoxen,_loc2_.showCartFront,_loc2_.showGlow,_loc3_);
         this.computeHeadsize();
         initTypesFromDef();
         apool.addPool(this.poleUrl,1,1);
         if(Boolean(saga) && Boolean(saga.caravan))
         {
            bannerUrl = saga.getBannerLengthUrl(true);
            if(bannerUrl)
            {
               apool.addPool(bannerUrl,1,1);
            }
            else
            {
               logger.error("CaravanViewClose: no banner url available!");
            }
            _loc6_ = saga.caravan._legend.roster;
            _loc7_ = 0;
            while(_loc7_ < _loc6_.numEntityDefs)
            {
               _loc8_ = _loc6_.getEntityDef(_loc7_);
               if((_loc8_.combatant || _loc8_.id == "juno") && _loc8_.id != this.ID_NARRATOR && _loc8_.id.indexOf("_tut") < 0)
               {
                  _loc9_ = _loc8_.entityClass.partyTag == "varl";
                  _loc10_ = _loc8_.id.indexOf("stonesinger") >= 0;
                  if(_loc10_)
                  {
                     _loc10_ = true;
                  }
                  _loc11_ = _loc9_ ? 20 : (_loc10_ ? 20 : 10);
                  _loc12_ = _loc11_ * 0.5 + Math.random() * _loc11_;
                  _loc13_ = this.T_HERO_PREFIX + _loc8_.id;
                  initType(_loc13_,_loc13_,0,_loc12_,_loc11_,!_loc9_);
               }
               _loc7_++;
            }
         }
         var _loc4_:int = -70;
         var _loc5_:int = -135;
         if(rightward)
         {
            _loc4_ *= -1;
         }
         createBanner(_loc4_,_loc5_,50);
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
      
      private function checkYoxen() : void
      {
         var _loc2_:Ati = null;
         var _loc3_:String = null;
         var _loc4_:CaravanViewTypeInfo = null;
         var _loc5_:Ati = null;
         var _loc6_:String = null;
         var _loc7_:CaravanViewTypeInfo = null;
         var _loc8_:Ati = null;
         var _loc9_:String = null;
         var _loc1_:int = population_index;
         while(_loc1_ < animTypes.length)
         {
            _loc2_ = animTypes[_loc1_];
            if(!_loc2_)
            {
               break;
            }
            _loc3_ = _loc2_.type.type;
            _loc4_ = getTypeInfo(_loc3_);
            if(_loc4_.trail)
            {
               _loc5_ = _loc1_ < animTypes.length - 1 ? animTypes[_loc1_ + 1] : null;
               _loc6_ = !!_loc5_ ? _loc5_.type.type : null;
               if(_loc6_ != _loc4_.trail)
               {
                  _loc7_ = getTypeInfo(_loc4_.trail);
                  animTypes.splice(_loc1_ + 1,0,new Ati(_loc7_));
                  _loc1_++;
                  _loc1_++;
                  continue;
               }
            }
            else if(_loc4_.lead)
            {
               _loc8_ = _loc1_ > 0 ? animTypes[_loc1_ - 1] : null;
               _loc9_ = !!_loc8_ ? _loc8_.type.type : null;
               if(_loc9_ != _loc4_.lead)
               {
                  removeTypeAt(_loc1_,null);
                  continue;
               }
            }
            _loc1_++;
         }
      }
      
      private function computeHeadsize() : void
      {
         this.headsize = 0;
         if(def.sprite_front)
         {
            ++this.headsize;
            if(def.sprite_front.trail)
            {
               ++this.headsize;
            }
         }
      }
      
      private function ensureNarrator(param1:Boolean) : void
      {
         population_index = num_heroes + this.num_narrator + this.num_extra;
         if(this.num_narrator == 0)
         {
            if(def.sprite_narrator)
            {
               ++this.num_narrator;
               ++population_index;
               addTypeAt(def.sprite_narrator.type,num_heroes + this.headsize,param1);
               if(def.sprite_narrator.trail)
               {
                  addTypeAt(def.sprite_narrator.trail,num_heroes + this.headsize + 1,param1);
                  ++population_index;
                  ++this.num_narrator;
               }
            }
         }
      }
      
      private function removeNarrator() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Ati = null;
         var _loc3_:String = null;
         var _loc4_:Ati = null;
         var _loc5_:String = null;
         this.num_narrator = 0;
         if(def.sprite_narrator)
         {
            _loc1_ = num_heroes + this.headsize;
            _loc2_ = animTypes.length > _loc1_ ? animTypes[_loc1_] : null;
            _loc3_ = !!_loc2_ ? _loc2_.type.type : null;
            if(_loc3_ == def.sprite_narrator.type)
            {
               removeTypeAt(_loc1_,null);
               _loc4_ = animTypes.length > _loc1_ ? animTypes[_loc1_] : null;
               _loc5_ = !!_loc4_ ? _loc4_.type.type : null;
               if(_loc5_ == def.sprite_narrator.trail)
               {
                  removeTypeAt(_loc1_,null);
               }
            }
         }
      }
      
      public function getSceneContext() : ILandscapeContext
      {
         if(cleanedup || !travel || !travel.landscape || !travel.landscape.scene)
         {
            return null;
         }
         return travel.landscape.scene._context;
      }
      
      public function getSaga() : Saga
      {
         var _loc1_:ILandscapeContext = this.getSceneContext();
         return !!_loc1_ ? _loc1_.saga as Saga : null;
      }
      
      private function checkNarrator(param1:Boolean) : void
      {
         var _loc2_:Saga = this.getSaga();
         var _loc3_:IEntityListDef = null;
         if(_loc2_ && _loc2_.caravan && Boolean(_loc2_.caravan._legend))
         {
            _loc3_ = _loc2_.caravan._legend.roster;
         }
         if(!_loc3_)
         {
            return;
         }
         var _loc4_:IEntityDef = _loc3_.getEntityDefById(this.ID_NARRATOR);
         if(_loc4_)
         {
            this.ensureNarrator(param1);
         }
         else
         {
            this.removeNarrator();
         }
      }
      
      private function ensureExtra(param1:Boolean) : void
      {
         population_index = num_heroes + this.num_narrator + this.num_extra;
         if(this.num_extra == 0)
         {
            if(def.sprite_extra)
            {
               ++this.num_extra;
               ++population_index;
               addTypeAt(def.sprite_extra.type,num_heroes + this.headsize,param1);
               if(def.sprite_extra.trail)
               {
                  addTypeAt(def.sprite_extra.trail,num_heroes + this.headsize + 1,param1);
                  ++population_index;
                  ++this.num_extra;
               }
            }
         }
      }
      
      private function removeExtra() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Ati = null;
         var _loc3_:String = null;
         var _loc4_:Ati = null;
         var _loc5_:String = null;
         this.num_extra = 0;
         if(def.sprite_extra)
         {
            _loc1_ = num_heroes + this.headsize;
            _loc2_ = animTypes.length > _loc1_ ? animTypes[_loc1_] : null;
            _loc3_ = !!_loc2_ ? _loc2_.type.type : null;
            if(_loc3_ == def.sprite_extra.type)
            {
               removeTypeAt(_loc1_,null);
               _loc4_ = animTypes.length > _loc1_ ? animTypes[_loc1_] : null;
               _loc5_ = !!_loc4_ ? _loc4_.type.type : null;
               if(_loc5_ == def.sprite_extra.trail)
               {
                  removeTypeAt(_loc1_,null);
               }
            }
         }
      }
      
      private function checkExtra(param1:Boolean) : void
      {
         var _loc2_:Saga = this.getSaga();
         var _loc3_:IEntityDef = _loc2_.caravan._legend.roster.getEntityDefById(this.ID_EXTRA);
         if(_loc3_)
         {
            this.ensureExtra(param1);
         }
         else
         {
            this.removeExtra();
         }
      }
      
      private function _buildHeroesList() : void
      {
         var _loc3_:IEntityDef = null;
         if(!saga || !saga.caravan || !saga.caravan._legend)
         {
            return;
         }
         var _loc1_:IEntityListDef = saga.caravan._legend.roster;
         var _loc2_:IPartyDef = saga.caravan._legend.party;
         this._heroesDict = new Dictionary();
         this._heroes.splice(0,this._heroes.length);
         var _loc4_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < _loc2_.numMembers)
         {
            _loc3_ = _loc2_.getMember(_loc4_);
            if(this._canShowHero(_loc3_))
            {
               this._heroes.push(_loc3_);
               this._heroesDict[_loc3_] = true;
            }
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < _loc1_.numEntityDefs)
         {
            _loc3_ = _loc1_.getEntityDef(_loc4_);
            if(this._canShowHero(_loc3_))
            {
               if(!this._heroesDict[_loc3_])
               {
                  this._heroes.push(_loc3_);
               }
            }
            _loc4_++;
         }
      }
      
      private function _canShowHero(param1:IEntityDef) : Boolean
      {
         var _loc2_:String = this.T_HERO_PREFIX + param1.id;
         if(!getTypeInfo(_loc2_))
         {
            return false;
         }
         if(!param1.combatant || param1.id == this.ID_NARRATOR)
         {
            if(param1.id != "juno")
            {
               return false;
            }
         }
         return true;
      }
      
      private function checkHeroes(param1:Boolean) : void
      {
         var _loc4_:IEntityDef = null;
         var _loc7_:String = null;
         if(cleanedup || !travel || !travel.landscape || !travel.landscape.scene || !travel.landscape.scene._context)
         {
            return;
         }
         var _loc2_:Saga = this.getSaga();
         if(!_loc2_ || !_loc2_.caravan || !_loc2_.caravan._legend)
         {
            return;
         }
         var _loc3_:IEntityListDef = _loc2_.caravan._legend.roster;
         if(!_loc3_)
         {
            return;
         }
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         _loc6_ = 0;
         while(_loc6_ < _loc3_.numEntityDefs)
         {
            _loc4_ = _loc3_.getEntityDef(_loc6_);
            if(this._canShowHero(_loc4_))
            {
               _loc5_++;
            }
            _loc6_++;
         }
         if(num_heroes != _loc5_)
         {
            this._buildHeroesList();
            _loc6_ = 0;
            while(_loc6_ < num_heroes)
            {
               removeTypeAt(0,null);
               _loc6_++;
            }
            _loc5_ = 0;
            for each(_loc4_ in this._heroes)
            {
               _loc7_ = this.T_HERO_PREFIX + _loc4_.id;
               if(!getTypeInfo(_loc7_))
               {
                  logger.error("No hero anim for [" + _loc4_.id + "]");
               }
               else
               {
                  addTypeAt(_loc7_,_loc5_,param1);
                  _loc5_++;
               }
            }
            num_heroes = this._heroes.length;
            computeStartT();
         }
      }
      
      private function checkHead() : void
      {
         var _loc1_:CaravanViewTypeInfo = null;
         var _loc2_:CaravanViewTypeInfo = null;
         if(animTypes.length == num_heroes)
         {
            if(def.sprite_front)
            {
               _loc1_ = getTypeInfo(def.sprite_front.type);
               animTypes.push(new Ati(_loc1_));
               if(def.sprite_front.trail)
               {
                  _loc2_ = getTypeInfo(def.sprite_front.trail);
                  animTypes.push(new Ati(_loc2_));
               }
            }
            computeStartT();
         }
      }
      
      override protected function postCheckAnims() : void
      {
         if(!banner)
         {
            return;
         }
         if(anims.length < num_heroes + 2)
         {
            return;
         }
         var _loc1_:DisplayObjectWrapper = anims[num_heroes + 1];
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:Number = _loc1_.rotationRadians;
         banner.update(_loc2_,caravan_t,_loc1_.x,_loc1_.y);
         if(this.pole)
         {
            this.pole.x = _loc1_.x + banner.banner_attach.x + banner.rotational_adjustment.x;
            this.pole.y = _loc1_.y + banner.banner_attach.y + banner.rotational_adjustment.y;
         }
      }
      
      override protected function checkAnims(param1:Boolean) : void
      {
         var _loc4_:CaravanViewSpriteDef = null;
         var _loc5_:TravelDef = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:CaravanViewTypeInfo = null;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         if(cleanedup || !travel || !travel.landscape || !travel.landscape.scene || !travel.landscape.scene._context)
         {
            return;
         }
         var _loc2_:Saga = this.getSaga();
         if(!_loc2_ || !_loc2_.caravan || !_loc2_.caravan._legend || !_loc2_.caravan._legend.roster)
         {
            return;
         }
         if(!this.pole && !this.poleFailed)
         {
            _loc5_ = travelView.travel.def;
            if(_loc5_.showBanner)
            {
               this.pole = apool.pop(this.poleUrl);
               if(this.pole == null)
               {
                  this.poleFailed = true;
                  logger.error("Failed to load the pole.");
                  return;
               }
               if(!rightward)
               {
                  this.pole.scaleX = -1;
               }
               if(displayObjectWrapper.numChildren > 0)
               {
                  displayObjectWrapper.addChildAt(this.pole,1);
               }
               else
               {
                  displayObjectWrapper.addChild(this.pole);
               }
            }
         }
         this.checkHeroes(param1);
         this.checkHead();
         this.checkNarrator(param1);
         this.checkExtra(param1);
         population_index = num_heroes + this.num_narrator + this.num_extra + 2;
         var _loc3_:Array = null;
         for each(_loc4_ in def.sprites_population)
         {
            _loc6_ = caravanVars.getVarInt(_loc4_.pop_varname);
            _loc7_ = Math.max(_loc4_.pop_mingroups,_loc6_ / _loc4_.pop_groupsize);
            _loc7_ = Math.min(_loc4_.pop_maxgroups,_loc7_);
            _loc8_ = int(currents[_loc4_.type]);
            _loc3_ = fillOutType(_loc7_,_loc8_,_loc4_.type,_loc3_);
            currents[_loc4_.type] = _loc7_;
         }
         if(Boolean(_loc3_) && _loc3_.length > 0)
         {
            randomizeAddedTypes(_loc3_);
            _loc9_ = _loc3_[0];
            _loc10_ = getTypeInfo(_loc9_);
            if(_loc10_.disallow_first)
            {
               _loc11_ = _loc3_.length - 1;
               while(_loc11_ >= 1)
               {
                  _loc12_ = _loc3_[_loc11_];
                  if(_loc12_ != _loc9_)
                  {
                     _loc3_[_loc11_] = _loc9_;
                     _loc3_[0] = _loc12_;
                     break;
                  }
                  _loc11_--;
               }
            }
         }
         this.checkYoxen();
      }
      
      override public function getRelativeHeroPosition(param1:String) : Number
      {
         update(0);
         var _loc2_:String = "hero_" + param1;
         var _loc3_:Number = travel.position;
         var _loc4_:Number = _loc3_;
         if(animSplineTs.length)
         {
            _loc4_ = animSplineTs[0] * travel.def.spline.totalLength;
         }
         _loc4_ += _loc3_;
         _loc4_ /= 2;
         var _loc5_:int = 0;
         while(_loc5_ < num_heroes)
         {
            if(animTypes[_loc5_].type.type == _loc2_)
            {
               if(animSplineTs.length > _loc5_)
               {
                  _loc4_ = animSplineTs[_loc5_] * travel.def.spline.totalLength;
                  break;
               }
            }
            _loc5_++;
         }
         return _loc3_ - _loc4_;
      }
   }
}
