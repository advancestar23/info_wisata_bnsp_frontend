import 'package:flutter/material.dart';
import '../data/api_service.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';

  bool loading = false;
  String? errorMessage;

  void _submit() async {
    // Panggil validate() untuk memicu validator di setiap field
    if (_formKey.currentState!.validate()) {
      // Jika valid, simpan state form
      _formKey.currentState!.save();
      setState(() {
        loading = true;
        errorMessage = null;
      });
      try {
        final result = await ApiServices.register(
          name: name,
          email: email,
          password: password,
        );
        if (result['status'] == 'success') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
        } else {
          // Jika API mengembalikan error di body
          errorMessage = result['message'] ?? 'Terjadi kesalahan';
        }
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
      } finally {
        setState(() {
          loading = false;
        });
      }
    } else {
      // Jika tidak valid, clear errorMessage agar hanya tampil validator
      setState(() {
        errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        width: double.infinity,
        height: double.infinity,

        // appBar: AppBar(title: Text("Login")),
        // body: Padding(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 4),
                  Text(
                    "Registrasi",
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Text(
                                errorMessage!,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          buildInputField(
                            label: 'nama',
                            onChanged: (val) => name = val,
                          ),
                          SizedBox(height: 4),
                          buildInputField(
                            label: 'email',
                            keyboardType: TextInputType.emailAddress,
                            validator:
                                (val) =>
                                    (val == null || !val.contains('@'))
                                        ? 'Email tidak valid'
                                        : null,
                            onChanged: (val) => email = val,
                          ),
                          buildInputField(
                            label: 'Password',
                            obscureText: true,
                            validator:
                                (val) =>
                                    val == null || val.isEmpty || val.length < 6
                                        ? 'Password tidak boleh kosong atau \n kurang dari 6 karakter'
                                        : null,
                            onChanged: (val) => password = val,
                          ),
                          SizedBox(height: 24),
                          loading
                              ? Center(child: CircularProgressIndicator())
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _submit,
                                    child: Text('Register'),
                                  ),
                                  SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LoginPage(),
                                        ),
                                      );
                                    },
                                    child: Text("Sudah punya akun? Login"),
                                  ),
                                ],
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildInputField({
  required String label,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  String? Function(String?)? validator,
  required void Function(String) onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator:
          validator ??
          (val) =>
              val == null || val.isEmpty ? '$label tidak boleh kosong' : null,
      onChanged: onChanged,
    ),
  );
}
