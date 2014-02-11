require 'spec_helper'

describe S2S::Auth do
  context "setup" do

    it "complains if you don't pass a required keys" do
      expect{ S2S::Auth.setup({})}.to raise_exception
    end

    it "sets values" do
      S2S::Auth.setup({secret: "this is my secret",
                       app: "test",
                       salt: "f7b5763636f4c1f3ff4bd444eacccca2",
                       sign_salt: "95d87b990cc104124017ad70550edcfd22b8e89465338254e0b608592a9aac29"
      })

      expect(S2S::Auth.settings[:app_name]).to eql("test")
      expect(S2S::Auth.settings[:salt]).to eql("f7b5763636f4c1f3ff4bd444eacccca2")
      expect(S2S::Auth.settings[:sign_salt]).to eql("95d87b990cc104124017ad70550edcfd22b8e89465338254e0b608592a9aac29")
    end

    it "sets an encryptor" do
      expect(S2S::Auth.settings[:encryptor]).to_not be_nil
    end

  end

  context "generate an auth header" do
    before(:all) do
      S2S::Auth.setup({secret: "this is my secret",
                       app: "another_test",
                       salt: "f7b5763636f4c1f3ff4bd444eacccca2",
                       sign_salt: "95d87b990cc104124017ad70550edcfd22b8e89465338254e0b608592a9aac29"
      })
    end

    it "can generate a header" do
      header = S2S::Auth.header
      expect(header.has_key?(:Authorization)).to be_true
      expect(header[:Authorization]).to match(/Bearer\s.{162}/)
    end

    it "can generate a token that can be converted back" do
      token = S2S::Auth.generate_token
      expect(token.length).to eql(194)
      crypt = S2S::Auth.settings[:encryptor]
      data = crypt.decrypt_and_verify(token)
      expect(data["app"]).to eql("another_test")
      # check that the time matches by getting the amount of seconds
      # since epoch.
      expect(Time.parse(data["ts"]).to_i).to eql(Time.now.to_i)
    end

    it "can parse a valid token" do
      token = S2S::Auth.generate_token
      data = S2S::Auth.parse_token(token)
      expect(data["app"]).to eql("another_test")
      # check that the time matches by getting the amount of seconds
      # since epoch.
      expect(Time.parse(data["ts"]).to_i).to eql(Time.now.to_i)
    end

    it "fails to parse a bad token" do
      token = "abFwNFBXSjhtRGZtZFJURzlvaG4zeTM1eTRMVVcvUmFjUFR4bWI0VjlSQUJuSWpGZWpFRjlHUnNxSWJWeENGNi0tKzgyMXRjeTU2TGJHL1pkSGlaUjBxZz09--454c07f2ae8dc744094128a6e68a02bc07dee003"
      expect{ S2S::Auth.parse_token(token) }.to raise_exception(ActiveSupport::MessageVerifier::InvalidSignature)
    end

  end
end
