#include <iostream>
#include <chrono>
#include <thread>
#include <mutex>
#include <condition_variable>

std::condition_variable cv;
std::mutex mtx;
bool fg = false;
bool fg_done = false;

using clk_type = std::chrono::steady_clock;
using timeunit_type = std::chrono::microseconds;

void run() {
    clk_type timer;
    std::chrono::time_point<clk_type> t_prev, t_now;
    auto t0 = timer.now();
    while (!fg_done) {
        t_now = timer.now();
        std::unique_lock <std::mutex> lck(mtx);
        cv.wait(lck, []{return fg;});
        fg = false;
        auto tt = std::chrono::duration_cast<timeunit_type>(t_now - t_prev).count();
            std::cout << tt << std::endl;
        t_prev = t_now;
    }
}

int main(int argc, char *argv[]) {

    std::thread thread(run);

    clk_type timer;
    auto t0 = timer.now();
    const auto t_elapsed = timeunit_type(1000);
    std::chrono::time_point<clk_type> t_trigger = t0;
    std::chrono::time_point<clk_type> t_prev, t_now;

    uint round = 1e4;

    for(uint i = 0; i < round; ++i) {
        /* 1 */
        t_trigger += t_elapsed;
        std::this_thread::sleep_until(t_trigger);
        /* 2 */
//        std::this_thread::sleep_for(t_elapsed);

        /* 3 */
//        auto start = clk_type::now();
//        std::this_thread::sleep_for(timeunit_type(100));
//        auto end = std::chrono::steady_clock::now();
//        auto elapsed = end - start;

//        auto timeToWait = t_elapsed - elapsed;
//        if(timeToWait > timeunit_type::zero())
//        {
//            std::this_thread::sleep_for(timeToWait);
//        }
        /* End */

        std::unique_lock <std::mutex> lck(mtx);
        fg = true;
        cv.notify_one();
    }

    fg_done = true;

    thread.join();
}
