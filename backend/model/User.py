from myapp import db,ma

class Mail(db.Model):
    __tablename__ = 'mail'
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(500))

    def __init__(self, email):
        self.email = email


class EmailSchema(ma.Schema):
    class Meta:
        fields = ('id', 'email')
