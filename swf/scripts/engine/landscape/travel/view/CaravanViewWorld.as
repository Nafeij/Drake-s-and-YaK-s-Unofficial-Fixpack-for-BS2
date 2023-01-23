package engine.landscape.travel.view
{
   import engine.landscape.travel.def.TravelDef;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.saga.CaravanViewDef;
   import engine.saga.CaravanViewSpriteDef;
   import engine.saga.Saga;
   
   public class CaravanViewWorld extends CaravanView
   {
       
      
      private var poleFailed:Boolean;
      
      public function CaravanViewWorld(param1:TravelView)
      {
         var _loc3_:CaravanViewSpriteDef = null;
         super(param1);
         var _loc2_:TravelDef = param1.travel.def;
         def = CaravanViewDef.ctorWorld(_loc2_.ships,_loc2_.showGlow,_loc2_.showYoxen,_loc2_.showCartFront,_loc2_.showMinCaravan);
         initTypeFromDef(def.sprite_front);
         for each(_loc3_ in def.sprites_population)
         {
            initTypeFromDef(_loc3_);
         }
         if(saga)
         {
            bannerUrl = saga.getBannerLengthUrl(false);
            if(bannerUrl)
            {
               apool.addPool(bannerUrl,1,1);
            }
         }
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(_loc2_.ships)
         {
            _loc4_ = -7;
            _loc5_ = -36;
         }
         else
         {
            _loc4_ = 14;
            _loc5_ = -30;
            if(!rightward)
            {
               _loc4_ *= -1;
            }
         }
         createBanner(_loc4_,_loc5_,0);
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
      
      private function checkHead() : void
      {
         var _loc1_:CaravanViewTypeInfo = null;
         if(animTypes.length == num_heroes)
         {
            if(def.sprite_front)
            {
               _loc1_ = getTypeInfo(def.sprite_front.type);
               animTypes.push(new Ati(_loc1_));
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
         if(anims.length < num_heroes + 1)
         {
            return;
         }
         var _loc1_:DisplayObjectWrapper = anims[num_heroes];
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:Number = _loc1_.rotationRadians;
         banner.update(_loc2_,caravan_t,_loc1_.x,_loc1_.y);
      }
      
      override protected function checkAnims(param1:Boolean) : void
      {
         var _loc4_:CaravanViewSpriteDef = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:CaravanViewTypeInfo = null;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         var _loc2_:Saga = Saga.instance;
         if(!_loc2_)
         {
            return;
         }
         if(!def)
         {
            return;
         }
         this.checkHead();
         population_index = num_heroes + 2;
         var _loc3_:Array = null;
         for each(_loc4_ in def.sprites_population)
         {
            if(_loc4_)
            {
               _loc5_ = caravanVars.getVarInt(_loc4_.pop_varname);
               _loc6_ = Math.max(_loc4_.pop_mingroups,_loc5_ / _loc4_.pop_groupsize);
               if((_loc5_ > 0 || _loc4_.pop_forcemin) && _loc6_ == 0)
               {
                  _loc6_ = 1;
               }
               _loc6_ = Math.min(_loc4_.pop_maxgroups,_loc6_);
               _loc7_ = int(currents[_loc4_.type]);
               _loc3_ = fillOutType(_loc6_,_loc7_,_loc4_.type,_loc3_);
               currents[_loc4_.type] = _loc6_;
            }
         }
         if(Boolean(_loc3_) && _loc3_.length > 0)
         {
            randomizeAddedTypes(_loc3_);
            _loc8_ = _loc3_[0];
            _loc9_ = getTypeInfo(_loc8_);
            if(_loc9_.disallow_first)
            {
               _loc10_ = _loc3_.length - 1;
               while(_loc10_ >= 1)
               {
                  _loc11_ = _loc3_[_loc10_];
                  if(_loc11_ != _loc8_)
                  {
                     _loc3_[_loc10_] = _loc8_;
                     _loc3_[0] = _loc11_;
                     break;
                  }
                  _loc10_--;
               }
            }
         }
      }
   }
}
