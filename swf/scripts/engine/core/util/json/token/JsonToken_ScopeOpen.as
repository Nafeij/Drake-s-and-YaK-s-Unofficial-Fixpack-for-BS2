package engine.core.util.json.token
{
   import engine.core.util.json.JsonToken;
   
   public class JsonToken_ScopeOpen extends JsonToken
   {
       
      
      public var matching_close:JsonToken_ScopeClose;
      
      public function JsonToken_ScopeOpen()
      {
         super();
      }
   }
}
