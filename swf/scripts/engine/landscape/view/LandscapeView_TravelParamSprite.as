package engine.landscape.view
{
   import engine.landscape.def.LandscapeSpriteDef;
   import engine.landscape.travel.def.LandscapeParamDef;
   import engine.landscape.travel.model.LandscapeParam;
   import engine.landscape.travel.model.LandscapeParamControl;
   import engine.landscape.travel.model.Travel;
   
   public class LandscapeView_TravelParamSprite
   {
       
      
      public var params:Vector.<LandscapeParam>;
      
      public var spriteDef:LandscapeSpriteDef;
      
      public var display:DisplayObjectWrapper;
      
      public var lv:LandscapeViewBase;
      
      public var initialized:Boolean;
      
      public function LandscapeView_TravelParamSprite(param1:LandscapeViewBase, param2:LandscapeSpriteDef, param3:DisplayObjectWrapper)
      {
         this.params = new Vector.<LandscapeParam>();
         super();
         this.lv = param1;
         this.spriteDef = param2;
         this.display = param3;
         this.update();
      }
      
      public function update() : void
      {
         var _loc1_:LandscapeParam = null;
         var _loc2_:Travel = null;
         var _loc3_:LandscapeParamDef = null;
         var _loc4_:LandscapeParamControl = null;
         var _loc5_:LandscapeParam = null;
         if(!this.initialized)
         {
            if(this.spriteDef.landscapeParams)
            {
               if(this.lv.travelView)
               {
                  _loc2_ = this.lv.travelView.travel;
                  for each(_loc3_ in this.spriteDef.landscapeParams)
                  {
                     _loc4_ = this.lv.landscape.getLandscapeParamControlById(_loc3_.controlId);
                     _loc5_ = new LandscapeParam(_loc3_,_loc4_);
                     this.params.push(_loc5_);
                  }
                  this.initialized = true;
               }
            }
         }
         if(!this.initialized)
         {
            return;
         }
         for each(_loc1_ in this.params)
         {
            if(_loc1_.control.valid)
            {
               if(_loc1_.lastOrdinal < _loc1_.control.ordinal)
               {
                  this.display[_loc1_.def.targetProperty] = _loc1_.control.value;
                  _loc1_.lastOrdinal = _loc1_.control.ordinal;
               }
            }
         }
      }
   }
}
