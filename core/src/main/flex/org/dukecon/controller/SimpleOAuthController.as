/**
 * Created by christoferdutz on 31.08.15.
 */
package org.dukecon.controller {

import flash.events.EventDispatcher;

import mx.rpc.AsyncToken;
import mx.rpc.Responder;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;

import org.dukecon.events.LoginChangedEvent;

[Event(type="org.dukecon.events.ConferenceDataChangedEvent", name="conferenceDataChanged")]
public class SimpleOAuthController extends EventDispatcher {

    private static var _instance:SimpleOAuthController;

    public static function get instance():SimpleOAuthController {
        if(!_instance) {
            _instance = new SimpleOAuthController(new SingletonEnforcer());
        }
        return _instance;
    }

    private var service:HTTPService;

    [Bindable]
    public var accessToken:String;

    public function SimpleOAuthController(enforcer:SingletonEnforcer) {
        service = new HTTPService();
        service.method = "POST";
        service.contentType = "application/x-www-form-urlencoded";
        service.headers = {Accept: "application/json"};
        service.url = "http://keycloak.dukecon.org/auth/realms/dukecon-latest/tokens/grants/access";
    }

    public function isLoggedIn():Boolean {
        return (accessToken != null);
    }

    public function login(username:String, password:String):void {
        var parameters:Object = {username: username, password: password,
            client_id: "flex", client_secret: "40a116ed-d97e-4a0d-8400-877fa58cbf99"};
        var token:AsyncToken = service.send(parameters);
        token.addResponder(new Responder(onResult, onFault));
        token.username = username;
    }

    public function logout():void {
        accessToken = null;
        dispatchEvent(new LoginChangedEvent(LoginChangedEvent.USER_LOGGED_OUT));
    }

    protected function onResult(event:ResultEvent):void {
        var result:Object = JSON.parse(String(event.result));
        accessToken = result["access_token"];
        dispatchEvent(new LoginChangedEvent(LoginChangedEvent.USER_LOGGED_IN,
                String(event.token.username), accessToken));
    }

    protected function onFault(event:FaultEvent):void {
        dispatchEvent(new LoginChangedEvent(LoginChangedEvent.USER_LOGIN_FAILURE));
    }

}
}
class SingletonEnforcer{}

