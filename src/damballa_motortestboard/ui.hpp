
#ifndef UI_HPP
#define UI_HPP

class Ui
{
public:
	enum Encoder
	{
		ENCODER_6,
		ENCODER_7,
	};
	
	static void
	initialize();
	
	static uint32_t
	getEncoder(Encoder encoder);
};

#endif // UI_HPP
