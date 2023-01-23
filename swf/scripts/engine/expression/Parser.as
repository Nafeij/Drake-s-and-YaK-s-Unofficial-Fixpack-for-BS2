package engine.expression
{
   import engine.core.logging.ILogger;
   import engine.expression.exp.Exp;
   
   public class Parser
   {
       
      
      public var raw:String;
      
      public var exp:Exp;
      
      public var tokens:Array;
      
      public var errors:Array;
      
      public var evalErrors:Array;
      
      public var logger:ILogger;
      
      public function Parser(param1:String, param2:ILogger)
      {
         var reg:RegExp;
         var result:Object;
         var lastIndex:int;
         var ss:String = null;
         var whites:int = 0;
         var raw:String = param1;
         var logger:ILogger = param2;
         this.tokens = [];
         this.errors = [];
         this.evalErrors = [];
         super();
         this.raw = raw;
         this.logger = logger;
         reg = /[\s\r\n]+|>=|<=|&&|\|\||>|!=|==|=|<|>|\(|\)|\!|\+|\-|\/|\%|\*|(?:\'.[^']*\')|\#*(?:[\w\.\#]?)+|\d*\.?\d*|true|false/g;
         result = reg.exec(raw);
         lastIndex = -1;
         while(result && result.index < raw.length && result.index > lastIndex)
         {
            lastIndex = int(result.index);
            ss = result[0];
            whites = ss.search(/[\s\r\n]+/);
            if(whites < 0)
            {
               this.tokens.push(result);
            }
            result = reg.exec(raw);
         }
         try
         {
            Exp.collectScopes(this.tokens);
            this.exp = Exp.factory(this.tokens);
         }
         catch(e:ErrorExp)
         {
            errors.push(e);
            if(logger)
            {
               logger.error(e.print(raw));
            }
         }
         catch(e:Error)
         {
            errors.push(e);
            if(logger)
            {
               logger.error(e.message);
            }
         }
      }
      
      private static function _printTokens(param1:Array, param2:String = "") : String
      {
         var _loc5_:Array = null;
         var _loc3_:String = "";
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc5_ = param1[_loc4_];
            if(!_loc5_)
            {
               _loc3_ += param2 + "ERROR";
            }
            else if(_loc5_[0] is Array)
            {
               _loc3_ += _printTokens(_loc5_,param2 + "  ");
            }
            else
            {
               _loc3_ += param2 + _loc5_[0] + "\n";
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function eval(param1:ISymbols) : Number
      {
         return this.evaluate(param1,true,this.logger);
      }
      
      public function evaluate(param1:ISymbols, param2:Boolean, param3:ILogger) : Number
      {
         var symbols:ISymbols = param1;
         var requireSymbols:Boolean = param2;
         var logger:ILogger = param3;
         this.evalErrors.splice(0,this.evalErrors.length);
         try
         {
            return this.exp.evaluate(symbols,requireSymbols);
         }
         catch(e:ErrorExp)
         {
            evalErrors.push(e);
            if(!logger)
            {
               throw e;
            }
            logger.error("Failed to evaluate expression: [" + raw + "]:\n" + e.print(raw));
            exp.evaluate(symbols,requireSymbols);
         }
         catch(e:Error)
         {
            evalErrors.push(e);
            if(!logger)
            {
               throw e;
            }
            logger.error("Failed to evaluate expression: [" + raw + "]:\n" + e.getStackTrace());
            exp.evaluate(symbols,requireSymbols);
         }
         return 0;
      }
      
      public function printParseErrors() : String
      {
         return this._printErrors(this.errors);
      }
      
      public function printEvalErrors() : String
      {
         return this._printErrors(this.evalErrors);
      }
      
      private function _printErrors(param1:Array) : String
      {
         var _loc3_:Error = null;
         var _loc4_:ErrorExp = null;
         var _loc2_:String = "";
         for each(_loc3_ in param1)
         {
            _loc4_ = _loc3_ as ErrorExp;
            if(_loc4_)
            {
               _loc2_ += _loc4_.print(this.raw);
            }
            else
            {
               _loc2_ += _loc3_.message;
            }
         }
         return _loc2_;
      }
      
      public function printTokens() : String
      {
         return _printTokens(this.tokens);
      }
   }
}
