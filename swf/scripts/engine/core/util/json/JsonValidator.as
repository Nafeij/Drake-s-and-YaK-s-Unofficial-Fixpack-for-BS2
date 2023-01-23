package engine.core.util.json
{
   import engine.core.logging.ILogger;
   import engine.core.util.json.token.JsonTokenCtor;
   
   public class JsonValidator
   {
       
      
      public var regex:RegExp;
      
      public var logger:ILogger;
      
      public var tokens:Vector.<JsonToken>;
      
      public function JsonValidator(param1:ILogger)
      {
         this.regex = /\".*?\"|[\[\]\{\}\:,]|(?:\w+)/g;
         this.tokens = new Vector.<JsonToken>();
         super();
         this.logger = param1;
      }
      
      public function validate(param1:String) : void
      {
         var _loc3_:JsonToken = null;
         var _loc2_:Array = this.regex.exec(param1);
         while(_loc2_)
         {
            _loc3_ = JsonTokenCtor.ctor(_loc2_[0],_loc2_.index,-9);
            this.tokens.push(_loc3_);
            _loc2_ = this.regex.exec(param1);
         }
      }
   }
}
