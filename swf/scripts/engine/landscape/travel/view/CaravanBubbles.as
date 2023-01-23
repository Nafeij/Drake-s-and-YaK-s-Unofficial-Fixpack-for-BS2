package engine.landscape.travel.view
{
   import engine.entity.def.IEntityDef;
   import engine.landscape.travel.def.TravelLocationDef;
   import engine.landscape.travel.model.Travel;
   import engine.saga.SpeakEvent;
   import engine.scene.view.ISpeechBubblePositioner;
   import engine.scene.view.SpeechBubble;
   import flash.geom.Point;
   
   public class CaravanBubbles implements ISpeechBubblePositioner
   {
       
      
      private var view:CaravanView;
      
      private var travel:Travel;
      
      public function CaravanBubbles(param1:CaravanView)
      {
         super();
         this.view = param1;
         this.travel = param1.travel;
      }
      
      public function cleanup() : void
      {
      }
      
      private function _adjustBubblePos(param1:IEntityDef, param2:Point) : void
      {
         var _loc3_:String = null;
         if(param1)
         {
            _loc3_ = param1.entityClass.race;
            if(_loc3_ == "varl")
            {
               param2.y -= 80;
            }
            else
            {
               param2.y -= 40;
            }
         }
         else
         {
            param2.y -= 30;
         }
      }
      
      public function positionSpeechBubble(param1:SpeechBubble) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Point = null;
         var _loc7_:Number = NaN;
         var _loc8_:Point = null;
         var _loc2_:Object = param1.positionerInfo as Object;
         var _loc3_:Boolean = Boolean(_loc2_.caravan);
         var _loc4_:Number = Number(_loc2_.pos);
         if(!isNaN(_loc4_))
         {
            _loc5_ = 0;
            if(_loc3_)
            {
               _loc5_ = this.travel.position + (this.travel.forward ? -_loc4_ : _loc4_);
            }
            else
            {
               _loc5_ = _loc4_;
            }
            _loc6_ = new Point();
            _loc7_ = _loc5_ * this.travel.def.spline.ooTotalLength;
            this.travel.def.spline.sample(_loc7_,_loc6_);
            this._adjustBubblePos(param1.entDef,_loc6_);
            _loc8_ = this.view.displayObjectWrapper.localToGlobal(_loc6_);
            param1.setPosition(_loc8_.x,_loc8_.y,false);
         }
      }
      
      public function handleCaravanSpeak(param1:SpeakEvent, param2:String) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:Number = NaN;
         var _loc3_:String = "travel.caravan";
         if(!param2 || param2.indexOf(_loc3_) == 0)
         {
            _loc4_ = 0;
            if(Boolean(param2) && param2.length > _loc3_.length)
            {
               _loc5_ = param2.substr(_loc3_.length + 1);
               _loc6_ = Number(_loc5_);
               if(!isNaN(_loc6_))
               {
                  _loc4_ = _loc6_;
               }
               if(_loc4_ == 0 && Boolean(param1.speakerDef))
               {
                  _loc4_ = this.view.getRelativeHeroPosition(param1.speakerDef.id);
               }
            }
            this.travel.landscape.scene._context.createSpeechBubble(param1,{
               "pos":_loc4_,
               "caravan":true
            },this);
            return true;
         }
         return false;
      }
      
      public function handleSplineSpeak(param1:SpeakEvent, param2:String) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:Number = NaN;
         var _loc7_:TravelLocationDef = null;
         var _loc3_:String = "travel.spline";
         if(param2.indexOf(_loc3_) == 0)
         {
            _loc4_ = this.travel.position;
            if(param2.length > _loc3_.length)
            {
               _loc5_ = param2.substr(_loc3_.length + 1);
               _loc6_ = Number(_loc5_);
               if(isNaN(_loc6_))
               {
                  _loc7_ = this.travel.def.findLocationById(_loc5_);
                  if(!_loc7_)
                  {
                     return true;
                  }
                  _loc4_ = _loc7_.position;
               }
               else
               {
                  _loc4_ = _loc6_;
               }
            }
            this.travel.landscape.scene._context.createSpeechBubble(param1,{
               "pos":_loc4_,
               "caravan":false
            },this);
            return true;
         }
         return false;
      }
      
      public function handleSpeak(param1:SpeakEvent, param2:String) : Boolean
      {
         if(!this.handleCaravanSpeak(param1,param2))
         {
            if(!this.handleSplineSpeak(param1,param2))
            {
               return false;
            }
         }
         return true;
      }
   }
}
