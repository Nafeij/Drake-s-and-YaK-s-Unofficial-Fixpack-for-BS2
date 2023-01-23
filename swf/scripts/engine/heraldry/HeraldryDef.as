package engine.heraldry
{
   import engine.math.Hash;
   import engine.saga.ISagaExpression;
   
   public class HeraldryDef
   {
      
      private static var _tempIdNum:int = 0;
       
      
      public var tags:int = 0;
      
      public var tagsArray:Array;
      
      public var id:String;
      
      public var bannerId:String;
      
      public var crestDef:CrestDef;
      
      public var _crestId:String;
      
      public var crestColor:uint;
      
      public var crownColor:uint;
      
      public var name:String;
      
      public var blendMode:String = "normal";
      
      public var prereq:String;
      
      public function HeraldryDef()
      {
         super();
      }
      
      public function createTempId() : void
      {
         this.id = "temp_" + (++_tempIdNum).toString();
         if(!this.name)
         {
            this.name = this.id;
         }
      }
      
      public function clone() : HeraldryDef
      {
         var _loc1_:HeraldryDef = new HeraldryDef();
         _loc1_.createTempId();
         _loc1_.bannerId = this.bannerId;
         _loc1_.crestColor = this.crestColor;
         _loc1_.crestDef = this.crestDef;
         _loc1_._crestId = this._crestId;
         _loc1_.crownColor = this.crownColor;
         _loc1_.blendMode = this.blendMode;
         _loc1_.prereq = this.prereq;
         _loc1_.tags = this.tags;
         _loc1_.tagsArray = !!this.tagsArray ? this.tagsArray.concat() : null;
         return _loc1_;
      }
      
      public function toString() : String
      {
         return this.id + ", " + this.bannerId + ", " + this._crestId;
      }
      
      public function filtered(param1:RegExp, param2:int, param3:ISagaExpression) : Boolean
      {
         var _loc4_:Boolean = false;
         if(param1)
         {
            if(!param1.test(this.name))
            {
               return false;
            }
         }
         if(Boolean(this.crestDef) && Boolean(this.crestDef.tags))
         {
            if(0 == (this.crestDef.tags & param2))
            {
               return false;
            }
            _loc4_ = true;
         }
         if(!_loc4_)
         {
            if(this.tags)
            {
               if(0 == (this.tags & param2))
               {
                  return false;
               }
            }
         }
         if(Boolean(param3) && Boolean(this.prereq))
         {
            if(!param3.evaluate(this.prereq,false))
            {
               return false;
            }
         }
         return true;
      }
      
      public function createHashId() : void
      {
         var _loc1_:uint = Hash.DJBHash(this.bannerId + this._crestId + this.crestColor.toString(16) + this.name + this.blendMode + this.crownColor.toString(16));
         this.id = _loc1_.toString(16);
      }
   }
}
