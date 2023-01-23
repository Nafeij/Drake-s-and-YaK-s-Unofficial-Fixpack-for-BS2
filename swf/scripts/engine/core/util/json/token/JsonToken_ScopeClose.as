package engine.core.util.json.token
{
   import engine.core.util.json.JsonToken;
   
   public class JsonToken_ScopeClose extends JsonToken
   {
       
      
      public var matching_open:JsonToken_ScopeOpen;
      
      public function JsonToken_ScopeClose()
      {
         super();
      }
   }
}
