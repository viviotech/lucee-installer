<cfinclude template="./assets/_public_header.cfm">

<div class="row">

	<div class="span2">
		<h2>Login</h2>
	</div>

	<div class="span14">

		<div class="alert-message block-message success">
			<p><strong>CFML Bootstrap Help</strong> This is the main login page.  Here we have a basic form that accepts the username/password for an application.  We control
			this using a simple Application.cfc setup; with the /secure/ directory being the place you have to be authenticated to be inside.  At this level, all pages are considered
			public.  Use <strong>demo</strong> / <strong>password</strong> to login.</p>
		</div>

		<form action="./secure/" method="post">

			<cfif StructKeyExists(session,"error")>
				<div class="alert-message error">
	  	    <p><cfoutput>#session.error#</cfoutput></p>
  	    </div>
				<cfset StructDelete(session,"error")>
			</cfif>

			<fieldset>
      <div class="clearfix">
	      <label for="xlInput">Username</label>
	      <div class="input">
	      	<input class="xlarge" id="username-login" name="_user" size="30" type="text" />
	      </div>
      </div>

      <div class="clearfix">
	      <label for="xlInput">Password</label>
	      <div class="input">
	      	<input class="xlarge" name="_pass" size="30" type="password" />
	      </div>
      </div>
			</fieldset>

			<div class="actions">
				<input class="btn primary" value="login" type="submit" />
			</div>

		</form>

	</div>

</div>

<script>
// Little piece of javascript to give the username input focus
document.getElementById("username-login").focus();
</script>

<cfinclude template="./assets/_public_footer.cfm">